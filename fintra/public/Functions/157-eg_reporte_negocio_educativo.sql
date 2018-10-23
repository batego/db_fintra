-- Function: eg_reporte_negocio_educativo()

-- DROP FUNCTION eg_reporte_negocio_educativo();

CREATE OR REPLACE FUNCTION eg_reporte_negocio_educativo()
  RETURNS SETOF record AS
$BODY$DECLARE
  reporteNegocio record;
  cuentas record;
  _ConceptRec record;
  sancion record;
  IxM numeric;
  GaC numeric;
  SumIxM numeric;
  SumGaC numeric;
  _Tasa numeric;
  semestrePerido numeric;
  diasVencidos numeric;
  vlrSaldo numeric;
  vlrSaldoVencido numeric;
  vlrSaldoFiducia numeric;
  ControlReg Text;
  VencimientoMayor Text;
  cuentaAval text;
  cuentaCapital text;
  cuentaInteres text;
  semestres text;
  negAux text;



BEGIN
   negAux ='';
   semestres='';
   vlrSaldoFiducia=0;
   cuentaAval='';
   cuentaCapital='';
   cuentaInteres='';

	  FOR reporteNegocio IN (
			SELECT
				fra.negasoc::varchar as negocio,
				get_nombrenit(neg.cod_cli)::varchar as nombre_cliente,
				neg.cod_cli::varchar as  cedula,
				get_nombp(neg.nit_tercero)::varchar as universidad,
				''::varchar as semestre,
				(SELECT SUM(capital) FROM documentos_neg_aceptado as dnega  where dnega.cod_neg =fra.negasoc):: numeric as capital,
				''::varchar as  cuenta_capital,
				neg.valor_aval::numeric,
				''::varchar as cuenta_aval,
				(SELECT SUM(interes) FROM documentos_neg_aceptado as dnega  where dnega.cod_neg =fra.negasoc):: numeric as Interes,
				''::varchar as cuenta_interes,
				(SELECT SUM(seguro) FROM documentos_neg_aceptado as dnega   where dnega.cod_neg =fra.negasoc):: numeric as Seguro,
				''::varchar as  cuenta_seguro,
				''::varchar as  Retorno_Seguro,
				''::varchar as  cuenta_retorno,
				''::varchar as  estudio_credito,
				''::varchar as  cuenta_estudio_credito,
				''::varchar as  vencimiento_mayor,
				(now()::date-fecha_vencimiento::DATE)::numeric as dias_vencidos,
				0::numeric as valor_saldo,
				0::numeric as valor_saldo_vencido,
				''::varchar as cuenta_saldo,
				0::numeric as interes_mora,
				0::numeric as gasto_cobranza,
				0::numeric as saldo_cartera_fenalco,
				''::varchar as cuenta_cartera_fenalco,
				fra.documento::varchar,
				frad.descripcion::varchar as prefijo,
				fra.num_doc_fen::varchar as cuota,
				fra.fecha_factura::date,
				fra.fecha_vencimiento::date,
				frad.valor_unitario::numeric as valor_saldo_unitario,
                                sum(fra.valor_saldo)::numeric as saldo_facturacion,
				neg.id_convenio::numeric,
				neg.creation_date::date,
				frad.codigo_cuenta_contable::varchar

			 FROM  con.factura fra
			 INNER JOIN con.factura_detalle as frad on (frad.documento=fra.documento)
			 INNER JOIN negocios as neg on (neg.cod_neg=fra.negasoc)
			 WHERE fra.dstrct = 'FINV'
				--AND fra.valor_saldo > 0
				  AND fra.reg_status = ''
			       --  AND fra.negasoc IN ('FA08443','FA08517')
				  AND fra.tipo_documento in ('FAC','NDC')
				  AND fra.reg_status = ''
	         		  AND neg.estado_neg = 'T'
				  AND neg.id_convenio in ('17','31','19')
				  AND substring(fra.documento,1,2) not in ('CP','FF','DF')
				  AND endoso_fenalco !='S'
                                  AND devuelta != 'S' and corficolombiana != 'S'
                                  --AND fra.num_doc_fen IN ('6','5')--QUITAR
			         -- and replace(substring(fra.fecha_vencimiento,1,7),'-','')::numeric <= replace(substring(now(),1,7),'-','')::numeric
			group  by fra.negasoc,
				  neg.cod_cli,
			          universidad,
				  neg.valor_aval,
				  fra.documento,
				  frad.descripcion,
				  fra.num_doc_fen,
				  fra.fecha_factura,
				  fra.fecha_vencimiento,
				  dias_vencidos,
				  nombre_cliente,
				  neg.id_convenio,
				  neg.creation_date,
				  frad.codigo_cuenta_contable,
				  frad.valor_unitario
			 order by  fra.negasoc,fra.num_doc_fen, fra.documento
			 )
	   LOOP

		IxM = 0;
		GaC = 0;
		SumIxM=0;
		SumGaC=0;

		SELECT INTO _ConceptRec * FROM conceptos_recaudo
		WHERE prefijo = reporteNegocio.prefijo
		AND reporteNegocio.dias_vencidos BETWEEN dias_rango_ini AND dias_rango_fin and id_unidad_negocio = 12;

		--sanciones
		FOR sancion IN (
			       SELECT * FROM sanciones_condonaciones
			       WHERE id_tipo_acto = 1
			       AND id_conceptos_recaudo = _ConceptRec.id
			       AND reporteNegocio.dias_vencidos BETWEEN dias_rango_ini AND dias_rango_fin
			       AND periodo = replace(substring(now(),1,7),'-','') and id_unidad_negocio = 12
			       )
		LOOP

			IF ( sancion.categoria = 'IXM' AND reporteNegocio.saldo_facturacion > 0) THEN

				if ( now()::date > reporteNegocio.fecha_vencimiento::date ) then

					select into _Tasa tasa_interes/100 from convenios where id_convenio = reporteNegocio.id_convenio;

					IxM = ROUND( reporteNegocio.valor_saldo_unitario * (_Tasa/30) * (reporteNegocio.dias_vencidos) ::numeric );
					SumIxM = SumIxM + IxM;
				end if;

			END IF;

			IF ( sancion.categoria = 'GAC' AND reporteNegocio.saldo_facturacion > 0 ) THEN

				if ( now()::date > reporteNegocio.fecha_vencimiento::date) then
					GaC = ROUND((reporteNegocio.valor_saldo_unitario * sancion.porcentaje::numeric)/100);
					SumGaC = SumGaC + GaC;
				end if;

			END IF;

		END LOOP;

		 reporteNegocio.interes_mora= SumIxM;
		 reporteNegocio.gasto_cobranza= SumGaC;
	   --sanciones

 --vamos hacer una super validacion



   IF (negAux='') THEN

	   vlrSaldoFiducia=0;
	   cuentaAval='';
	   cuentaCapital='';
	   cuentaInteres='';
	   vlrSaldoVencido :=0;


	   negAux=reporteNegocio.negocio;
		     /* Vencimiento Mayor */

		     SELECT INTO VencimientoMayor CASE WHEN maxdia >= 365 THEN '8- MAYOR A 1 AÑO'
					     WHEN maxdia >= 181 THEN '7- ENTRE 180 Y 360'
					     WHEN maxdia >= 121 THEN '6- ENTRE 121 Y 180'
					     WHEN maxdia >= 91 THEN '5- ENTRE 91 Y 120'
					     WHEN maxdia >= 61 THEN '4- ENTRE 61 Y 90'
					     WHEN maxdia >= 31 THEN '3- ENTRE 31 Y 60'
					     WHEN maxdia >= 1 THEN '2- 1 A 30'
					     WHEN maxdia <= 0 THEN '1- CORRIENTE'
					ELSE '0' END AS rango
				FROM (
					 SELECT max(now()::date-(fecha_vencimiento)) as maxdia
					 FROM  con.factura fra
					 WHERE fra.dstrct = 'FINV'
						  AND fra.valor_saldo > 0
						  AND fra.reg_status = ''
						  AND fra.negasoc = reporteNegocio.negocio
						  AND fra.tipo_documento in ('FAC','NDC')
						  AND substring(documento,1,2) not in ('CP','FF','DF')
						  AND endoso_fenalco !='S'
						  AND devuelta != 'S' and corficolombiana != 'S'
						  AND replace(substring(fra.fecha_vencimiento,1,7),'-','')::numeric <= replace(substring(now(),1,7),'-','')::numeric
					 GROUP BY negasoc

				)tabla2;



				IF FOUND THEN
				reporteNegocio.vencimiento_mayor = VencimientoMayor;
				ELSE
				 VencimientoMayor='1- CORRIENTE';
				 reporteNegocio.vencimiento_mayor='1- CORRIENTE';
				END IF;

		      /* fin Vencimiento Mayor */

		      /* dias vencidos*/

			   SELECT INTO diasVencidos *
				FROM (
					 SELECT max(now()::date-(fecha_vencimiento)) as maxdia
					 FROM  con.factura fra
					 WHERE fra.dstrct = 'FINV'
						  AND fra.valor_saldo > 0
						  AND fra.reg_status = ''
						  AND fra.negasoc = reporteNegocio.negocio
						  AND fra.tipo_documento in ('FAC','NDC')
						  AND substring(documento,1,2) not in ('CP','FF','DF')
						  AND endoso_fenalco !='S'
						  AND devuelta != 'S' and corficolombiana != 'S'
						--  AND replace(substring(fra.fecha_vencimiento,1,7),'-','')::numeric <= replace(substring(now(),1,7),'-','')::numeric
					 GROUP BY negasoc

				)tabla2;

				RAISE NOTICE 'DIAS VENCIDOS 1 :%',diasVencidos;

				reporteNegocio.dias_vencidos=diasVencidos;

		      /* fin dias vencidos*/

		      /*valor saldo negocio principal*/


			SELECT into vlrSaldo sum(valor_saldo) from con.factura fra
			WHERE fra.negasoc = reporteNegocio.negocio
			  AND fra.tipo_documento in ('FAC','NDC')
			--  AND fra.valor_saldo > 0
			  AND fra.reg_status = ''
			  AND substring(fra.documento,1,2) not in ('CP','FF','DF')
			  AND endoso_fenalco !='S'
			  AND devuelta != 'S' and corficolombiana != 'S';

			reporteNegocio.valor_saldo=vlrSaldo;
		      /* fin valor saldo*/


			 /*valor saldo negocio lo vencido principal*/


			SELECT into vlrSaldoVencido sum(valor_saldo) from con.factura fra
			WHERE fra.negasoc = reporteNegocio.negocio
			  AND fra.tipo_documento in ('FAC','NDC')
			--  AND fra.valor_saldo > 0
			  AND fra.reg_status = ''
			  AND substring(fra.documento,1,2) not in ('CP','FF','DF')
			  AND endoso_fenalco !='S'
			  AND devuelta != 'S' and corficolombiana != 'S'
			  AND fra.fecha_vencimiento ::date < now()::date;

			raise notice 'saldo vencido %',vlrSaldoVencido;
			if(found) then
			reporteNegocio.valor_saldo_vencido=vlrSaldoVencido;
			end if;
		      /* fin valor saldo vencido */



		      /* valor saldo fenalco */
			vlrSaldoFiducia=0;
			SELECT into vlrSaldoFiducia COALESCE(sum(valor_saldo),0)  from con.factura fra
			where fra.negasoc = reporteNegocio.negocio
			 AND fra.tipo_documento in ('FAC','NDC')
		       --  AND fra.valor_saldo > 0
			 AND fra.reg_status = ''
			 AND substring(fra.documento,1,2)  in ('CP','FF','DF');

			 if vlrSaldoFiducia is not null then reporteNegocio.saldo_cartera_fenalco=vlrSaldoFiducia; end if;

		    /* valor saldo fenalco */

		    /* semestre */
		       semestrePerido =  date_part('month', reporteNegocio.creation_date);

		       IF (semestrePerido >= 1 AND semestrePerido <= 4) THEN
			    semestres= '1 SEMESTRE '||date_part('year', reporteNegocio.creation_date);
		       ELSIF(semestrePerido >= 5 AND semestrePerido <= 10) THEN
			    semestres= '2 SEMESTRE ' ||date_part('year', reporteNegocio.creation_date);
		       ELSE
			    semestres= '1 SEMESTRE ' ||(date_part('year', reporteNegocio.creation_date) + 1);
		       END IF;

		       reporteNegocio.semestre=semestres;

		    /* fin semestre */




		    FOR cuentas in (
				  SELECT frad.descripcion,frad.valor_unitario,frad.codigo_cuenta_contable FROM con.factura fra
				  INNER JOIN con.factura_detalle frad on (fra.documento=frad.documento)
				  WHERE fra.negasoc = reporteNegocio.negocio
					AND fra.dstrct = 'FINV'
					AND fra.valor_saldo > 0
					AND fra.reg_status = ''
					AND fra.tipo_documento in ('FAC','NDC')
					AND frad.reg_status = ''
					AND substring(fra.documento,1,2) not in ('CP','FF','DF')
					AND devuelta != 'S' and corficolombiana != 'S'

			      )
		    LOOP
			IF ( cuentas.descripcion = 'AVAL') THEN
			cuentaAval=cuentas.codigo_cuenta_contable;

			END IF;
			IF ( cuentas.descripcion = 'CAPITAL') THEN
			cuentaCapital=cuentas.codigo_cuenta_contable;

			END IF;
			IF ( cuentas.descripcion = 'INTERESES') THEN
			cuentaInteres=cuentas.codigo_cuenta_contable;

			END IF;

		    END LOOP;

		   reporteNegocio.cuenta_aval=cuentaAval;
		   reporteNegocio.cuenta_capital=cuentaCapital;
		   reporteNegocio.cuenta_interes=cuentaInteres;



        ELSIF(negAux = reporteNegocio.negocio)THEN

			raise notice 'dias vencidos igual %',diasVencidos;

		       reporteNegocio.vencimiento_mayor = VencimientoMayor;
		       reporteNegocio.dias_vencidos=diasVencidos;
		       reporteNegocio.valor_saldo=vlrSaldo;
		       reporteNegocio.valor_saldo_vencido=vlrSaldoVencido;
		       reporteNegocio.saldo_cartera_fenalco=vlrSaldoFiducia;
		       reporteNegocio.semestre=semestres;
		       reporteNegocio.cuenta_aval=cuentaAval;
		       reporteNegocio.cuenta_capital=cuentaCapital;
		       reporteNegocio.cuenta_interes=cuentaInteres;


        ELSIF (negAux != reporteNegocio.negocio) THEN
		vlrSaldoFiducia :=0;
	        vlrSaldoVencido :=0;
		diasVencidos :=0;
		cuentaAval :='';
		cuentaCapital :='';
		cuentaInteres :='';
		negAux=reporteNegocio.negocio;
		     /* Vencimiento Mayor */

		     SELECT INTO VencimientoMayor CASE WHEN maxdia >= 365 THEN '8- MAYOR A 1 AÑO'
					     WHEN maxdia >= 181 THEN '7- ENTRE 180 Y 360'
					     WHEN maxdia >= 121 THEN '6- ENTRE 121 Y 180'
					     WHEN maxdia >= 91 THEN '5- ENTRE 91 Y 120'
					     WHEN maxdia >= 61 THEN '4- ENTRE 61 Y 90'
					     WHEN maxdia >= 31 THEN '3- ENTRE 31 Y 60'
					     WHEN maxdia >= 1 THEN '2- 1 A 30'
					     WHEN maxdia <= 0 THEN '1- CORRIENTE'
					ELSE '0' END AS rango
				FROM (
					 SELECT max(now()::date-(fecha_vencimiento)) as maxdia
					 FROM  con.factura fra
					 WHERE fra.dstrct = 'FINV'
						  AND fra.valor_saldo > 0
						  AND fra.reg_status = ''
						  AND fra.negasoc = reporteNegocio.negocio
						  AND fra.tipo_documento in ('FAC','NDC')
						  AND substring(documento,1,2) not in ('CP','FF','DF')
						  AND endoso_fenalco !='S'
						  AND devuelta != 'S' and corficolombiana != 'S'
						  AND replace(substring(fra.fecha_vencimiento,1,7),'-','')::numeric <= replace(substring(now(),1,7),'-','')::numeric
					 GROUP BY negasoc

				)tabla2;

				IF FOUND THEN
				reporteNegocio.vencimiento_mayor = VencimientoMayor;
				ELSE
				VencimientoMayor='1- CORRIENTE';
				reporteNegocio.vencimiento_mayor = '1- CORRIENTE';
				END IF;
		      /* fin Vencimiento Mayor */

		      /* dias vencidos*/

			   SELECT INTO diasVencidos *
				FROM (
					 SELECT max(now()::date-(fecha_vencimiento)) as maxdia
					 FROM  con.factura fra
					 WHERE fra.dstrct = 'FINV'
						  AND fra.valor_saldo > 0
						  AND fra.reg_status = ''
						  AND fra.negasoc = reporteNegocio.negocio
						  AND fra.tipo_documento in ('FAC','NDC')
						  AND substring(documento,1,2) not in ('CP','FF','DF')
						  AND endoso_fenalco !='S'
						  AND devuelta != 'S' and corficolombiana != 'S'
						 -- AND replace(substring(fra.fecha_vencimiento,1,7),'-','')::numeric <= replace(substring(now(),1,7),'-','')::numeric
					 GROUP BY negasoc

				)tabla2;

				raise notice 'negocio : % dias vencidos 2: %',reporteNegocio.negocio,diasVencidos;
				reporteNegocio.dias_vencidos=diasVencidos;

		      /* fin dias vencidos*/

		      /*valor saldo negocio principal*/


			SELECT into vlrSaldo sum(valor_saldo) from con.factura fra
			WHERE fra.negasoc = reporteNegocio.negocio
			  AND fra.tipo_documento in ('FAC','NDC')
			--  AND fra.valor_saldo > 0
			  AND fra.reg_status = ''
			  AND substring(fra.documento,1,2) not in ('CP','FF','DF')
			  AND endoso_fenalco !='S'
			  AND devuelta != 'S' and corficolombiana != 'S';

			reporteNegocio.valor_saldo=vlrSaldo;
		      /* fin valor saldo*/

			 /*valor saldo negocio lo vencido principal*/


			SELECT into vlrSaldoVencido sum(valor_saldo) from con.factura fra
			WHERE fra.negasoc = reporteNegocio.negocio
			  AND fra.tipo_documento in ('FAC','NDC')
			--  AND fra.valor_saldo > 0
			  AND fra.reg_status = ''
			  AND substring(fra.documento,1,2) not in ('CP','FF','DF')
			  AND endoso_fenalco !='S'
			  AND devuelta != 'S' and corficolombiana != 'S'
			  AND fra.fecha_vencimiento ::date < now()::date;


			reporteNegocio.valor_saldo_vencido=vlrSaldoVencido;

		      /* fin valor saldo vencido */


		      /* valor saldo fiducia */
			vlrSaldoFiducia=0;
			SELECT into vlrSaldoFiducia COALESCE(sum(valor_saldo),0) from con.factura fra
			where fra.negasoc = reporteNegocio.negocio
			 AND fra.tipo_documento in ('FAC','NDC')
		       --  AND fra.valor_saldo > 0
			 AND fra.reg_status = ''
			 AND substring(fra.documento,1,2)  in ('CP','FF','DF');

			 if vlrSaldoFiducia is not null then reporteNegocio.saldo_cartera_fenalco=vlrSaldoFiducia; end if;

		    /* valor saldo fiducia */

		    /* semestre */
		       semestrePerido =  date_part('month', reporteNegocio.creation_date);

		       IF (semestrePerido >= 1 AND semestrePerido <= 4) THEN
			    semestres= '1 SEMESTRE '||date_part('year', reporteNegocio.creation_date);
		       ELSIF(semestrePerido >= 5 AND semestrePerido <= 10) THEN
			    semestres= '2 SEMESTRE ' ||date_part('year', reporteNegocio.creation_date);
		       ELSE
			    semestres= '1 SEMESTRE ' ||(date_part('year', reporteNegocio.creation_date) + 1);
		       END IF;

		       reporteNegocio.semestre=semestres;

		    /* fin semestre */



		    FOR cuentas in (
				  SELECT frad.descripcion,frad.valor_unitario,frad.codigo_cuenta_contable FROM con.factura fra
				  INNER JOIN con.factura_detalle frad on (fra.documento=frad.documento)
				  WHERE fra.negasoc = reporteNegocio.negocio
					AND fra.dstrct = 'FINV'
					AND fra.valor_saldo > 0
					AND fra.reg_status = ''
					AND fra.tipo_documento in ('FAC','NDC')
					AND frad.reg_status = ''
					AND substring(fra.documento,1,2) not in ('CP','FF','DF')
					AND devuelta != 'S' and corficolombiana != 'S'

			      )
		    LOOP
			IF ( cuentas.descripcion = 'AVAL') THEN
			cuentaAval=  cuentas.codigo_cuenta_contable;

			END IF;
			IF ( cuentas.descripcion = 'CAPITAL') THEN
			cuentaCapital=cuentas.codigo_cuenta_contable;

			END IF;
			IF ( cuentas.descripcion = 'INTERESES') THEN
			cuentaInteres=cuentas.codigo_cuenta_contable;

			END IF;

		    END LOOP;

		   reporteNegocio.cuenta_aval=cuentaAval;
		   reporteNegocio.cuenta_capital=cuentaCapital;
		   reporteNegocio.cuenta_interes=cuentaInteres;



	END IF;
  -- fin super validacion

   RETURN NEXT reporteNegocio;

END LOOP;

END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_reporte_negocio_educativo()
  OWNER TO postgres;
