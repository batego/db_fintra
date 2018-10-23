-- Function: eg_reporte_negocio_automotor()

-- DROP FUNCTION eg_reporte_negocio_automotor();

CREATE OR REPLACE FUNCTION eg_reporte_negocio_automotor()
  RETURNS SETOF record AS
$BODY$DECLARE

  reporteNegocio record;

  _ConceptRec record;
  documentosNegAceptado record;
  sancion record;
  IxM numeric:=0;
  GaC numeric:=0;
  SumIxM numeric:=0;
  SumGaC numeric:=0;
  _Tasa numeric:=0;
  diasVencidos numeric:=0;
  vlrSaldo numeric:=0;
  vlrSaldoVencido numeric:=0;
  vlrSaldoFiducia numeric:=0;
  capital_neg numeric:=0;
  interes_neg numeric:=0;
  valor_aval_neg numeric:=0;
  interes_aval_neg numeric:=0;
  vlrSaldoAval numeric:=0;
  vlrSaldoVencidoAval numeric:=0;

  VencimientoMayor Text;
  negAux text:='';
  negocioAval text:='';



BEGIN

	FOR reporteNegocio IN (

			(
			SELECT
				fra.negasoc::varchar as negocio,
				get_nombrenit(neg.cod_cli)::varchar as nombre_cliente,
				neg.cod_cli::varchar as  cedula,
				get_nombp(neg.nit_tercero)::varchar as afiliado,
				neg.creation_date::date,
				neg.fecha_ap::date,
				frad.descripcion::varchar as prefijo,
				fecha_vencimiento::date,
				fra.num_doc_fen::varchar as cuota,
				0:: numeric as capital,
				neg.valor_remesa::numeric,
				0::numeric as Interes,
				''::text as negocio_aval,
				0::numeric as valor_aval,
				0::numeric as Interes_aval,
				0::numeric as valor_saldo_aval,
				0::numeric as valor_saldo_aval_vencido,
				sum(fra.valor_saldo)::numeric as saldo_facturacion,
				frad.valor_unitario::numeric as valor_saldo_unitario,
				''::varchar as  vencimiento_mayor,
				(now()::date-fecha_vencimiento::DATE)::numeric as dias_vencidos,
				0::numeric as valor_saldo,
				0::numeric as valor_saldo_vencido,
				0::numeric as interes_mora,
				0::numeric as gasto_cobranza,
				neg.id_convenio::numeric,
				neg.nro_docs::varchar as plazo,
				(SELECT count(0) as cuotas_vencidas
					from con.factura
					where reg_status = ''
					and dstrct = 'FINV' and tipo_documento in ('FAC','NDC')
					and valor_saldo > 0
					and negasoc =fra.negasoc
					and fecha_vencimiento <= now()
					and substring(documento,1,2) not in ('CP','FF','DF')
					and descripcion not in ('CXC AVAL','CXC_INTERES_FA','CXC_CAT_MC','CXC_INTERES_MC'))::int as  cuotas_vencidas,
				nl.valor_fasecolda::numeric,
				nl.marca::varchar,
				nl.modelo::varchar,
				nl.clase::varchar,
				nl.servicio::varchar

			 FROM  con.factura fra
			 INNER JOIN con.factura_detalle as frad on (frad.documento=fra.documento)
			 INNER JOIN negocios as neg on (neg.cod_neg=fra.negasoc)
			 LEFT JOIN administrativo.garantias_negocios_automotor  nl on (nl.cod_neg=neg.cod_neg)
			 WHERE fra.dstrct = 'FINV'
				--AND fra.valor_saldo > 0
				  AND fra.reg_status = ''
				  AND neg.financia_aval = true
				  AND neg.negocio_rel=''
				  ---AND fra.negasoc IN ('')
				  AND fra.tipo_documento in ('FAC','NDC')
				  AND fra.reg_status = ''
				  AND neg.estado_neg = 'T'
				  AND neg.id_convenio in ('16','30','26')
				  AND substring(fra.documento,1,2) not in ('CP','FF','DF')
				  AND endoso_fenalco !='S'
				  AND devuelta != 'S' and corficolombiana != 'S'

			group  by fra.negasoc,
				  neg.cod_cli,
				  nombre_cliente,
				  cedula,
				  afiliado,
				  neg.creation_date,
				  neg.fecha_ap,
				  fra.num_doc_fen,
				  neg.valor_remesa,
				  neg.id_convenio,
				  fecha_vencimiento,
				  frad.descripcion,
				  frad.valor_unitario,
				  neg.nro_docs,
				  nl.valor_fasecolda,
				  nl.marca,
				  nl.modelo,
				  nl.clase,
				  nl.servicio

			order by  fra.negasoc, fecha_vencimiento asc
			)
			UNION ALL
			(
			SELECT
				fra.negasoc::varchar as negocio,
				get_nombrenit(neg.cod_cli)::varchar as nombre_cliente,
				neg.cod_cli::varchar as  cedula,
				get_nombp(neg.nit_tercero)::varchar as afiliado,
				neg.creation_date::date,
				neg.fecha_ap::date,
				frad.descripcion::varchar as prefijo,
				fecha_vencimiento::date,
				fra.num_doc_fen::varchar as cuota,
				0:: numeric as capital,
				neg.valor_remesa::numeric,
				0::numeric as Interes,
				''::text as negocio_aval,
				0::numeric as valor_aval,
				0::numeric as Interes_aval,
				0::numeric as valor_saldo_aval,
				0::numeric as valor_saldo_aval_vencido,
				sum(fra.valor_saldo)::numeric as saldo_facturacion,
				frad.valor_unitario::numeric as valor_saldo_unitario,
				''::varchar as  vencimiento_mayor,
				(now()::date-fecha_vencimiento::DATE)::numeric as dias_vencidos,
				0::numeric as valor_saldo,
				0::numeric as valor_saldo_vencido,
				0::numeric as interes_mora,
				0::numeric as gasto_cobranza,
				neg.id_convenio::numeric,
				neg.nro_docs::varchar as plazo,
				(SELECT count(0) as cuotas_vencidas
					from con.factura
					where reg_status = ''
					and dstrct = 'FINV' and tipo_documento in ('FAC','NDC')
					and valor_saldo > 0
					and negasoc =fra.negasoc
					and fecha_vencimiento <= now()
					and substring(documento,1,2) not in ('CP','FF','DF')
					and descripcion not in ('CXC AVAL','CXC_INTERES_FA','CXC_CAT_MC','CXC_INTERES_MC'))::int as  cuotas_vencidas,
				nl.valor_fasecolda::numeric,
				nl.marca::varchar,
				nl.modelo::varchar,
				nl.clase::varchar,
				nl.servicio::varchar

			 FROM  con.factura fra
			 INNER JOIN con.factura_detalle as frad on (frad.documento=fra.documento)
			 INNER JOIN negocios as neg on (neg.cod_neg=fra.negasoc)
			 LEFT JOIN administrativo.garantias_negocios_automotor  nl on (nl.cod_neg=neg.cod_neg)
			 WHERE fra.dstrct = 'FINV'
				--AND fra.valor_saldo > 0
				  AND fra.reg_status = ''
				 -- AND neg.financia_aval = true
				  AND neg.negocio_rel=''
				  AND fra.negasoc LIKE 'NG%'
				  AND fra.tipo_documento in ('FAC','NDC')
				  AND fra.reg_status = ''
				  AND neg.estado_neg = 'T'
				  AND neg.id_convenio in ('16','30','26')
				  AND substring(fra.documento,1,2) not in ('CP','FF','DF')
				  AND endoso_fenalco !='S'
				  AND devuelta != 'S' and corficolombiana != 'S'

			group  by fra.negasoc,
				  neg.cod_cli,
				  nombre_cliente,
				  cedula,
				  afiliado,
				  neg.creation_date,
				  neg.fecha_ap,
				  fra.num_doc_fen,
				  neg.valor_remesa,
				  neg.id_convenio,
				  fecha_vencimiento,
				  frad.descripcion,
				  frad.valor_unitario,
				  neg.nro_docs,
				  nl.valor_fasecolda,
				  nl.marca,
				  nl.modelo,
				  nl.clase,
				  nl.servicio

			 order by  fra.negasoc, fecha_vencimiento asc

			)
			)
        LOOP

		/* ** Calculo de sanciones IxM - GAC **/

		IxM = 0;
		GaC = 0;
		SumIxM=0;
		SumGaC=0;

		SELECT INTO _ConceptRec * FROM conceptos_recaudo
		WHERE prefijo = reporteNegocio.prefijo
		AND reporteNegocio.dias_vencidos BETWEEN dias_rango_ini AND dias_rango_fin and id_unidad_negocio = 3;


		FOR sancion IN (
			       SELECT * FROM sanciones_condonaciones
			       WHERE id_tipo_acto = 1
			       AND id_conceptos_recaudo = _ConceptRec.id
			       AND reporteNegocio.dias_vencidos BETWEEN dias_rango_ini AND dias_rango_fin
			       AND periodo = replace(substring(now(),1,7),'-','') and id_unidad_negocio = 3
			       )
		LOOP

			IF ( sancion.categoria = 'IXM' AND reporteNegocio.saldo_facturacion > 0) THEN

				if ( now()::date > reporteNegocio.fecha_vencimiento::date ) then

					select into _Tasa tasa_interes/100 from convenios where id_convenio = reporteNegocio.id_convenio;

					IxM = ROUND( reporteNegocio.valor_saldo_unitario * (_Tasa/30) * (reporteNegocio.dias_vencidos) ::numeric );
					SumIxM := SumIxM + IxM;

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

		/* ** Fin sanciones IxM - GAC **/

		/*Creamos un control de iteraciones por negocio para mejorar el rendimiento */

		IF (negAux='') THEN

		  RAISE NOTICE 'SE EJECUTA SOLO UNA VEZ';
		  negAux := reporteNegocio.negocio ;

			/* *Buscamos capital,interes */
			SELECT INTO documentosNegAceptado SUM(capital)::numeric as capital, SUM(interes)::numeric as interes
			FROM documentos_neg_aceptado AS dnega
			WHERE dnega.cod_neg =reporteNegocio.negocio ;

			capital_neg :=documentosNegAceptado.capital;
			interes_neg :=documentosNegAceptado.interes;

			/*Buscamos negocio de aval*/
			SELECT INTO negocioAval cod_neg FROM negocios WHERE negocio_rel=reporteNegocio.negocio limit 1;
			raise notice 'negocio padre: % negocio aval %',reporteNegocio.negocio,negocioAval;
			/* *Buscamos valor aval,interes aval*/
			SELECT INTO valor_aval_neg vr_negocio FROM negocios WHERE negocio_rel= reporteNegocio.negocio ;

			SELECT INTO interes_aval_neg SUM(interes) FROM documentos_neg_aceptado AS dnega
			WHERE dnega.cod_neg = negocioAval;

			 /* *Vencimiento Mayor */

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

					 GROUP BY negasoc

			)tabla2;

			/*valor saldo negocio*/
		        SELECT into vlrSaldo sum(valor_saldo) FROM  con.factura fra
			 WHERE fra.negasoc = reporteNegocio.negocio
			  AND fra.tipo_documento in ('FAC','NDC')
			  AND fra.reg_status = ''
			  AND substring(fra.documento,1,2) not in ('CP','FF','DF')
			  AND endoso_fenalco !='S'
			  AND devuelta != 'S' and corficolombiana != 'S';

			 /*valor saldo negocio  vencido*/

			SELECT into vlrSaldoVencido coalesce(sum(valor_saldo),0) from con.factura fra
			WHERE fra.negasoc = reporteNegocio.negocio
			  AND fra.tipo_documento in ('FAC','NDC')
			  AND fra.reg_status = ''
			  AND substring(fra.documento,1,2) not in ('CP','FF','DF')
			  AND endoso_fenalco !='S'
			  AND devuelta != 'S' and corficolombiana != 'S'
			  AND fra.fecha_vencimiento ::date < now()::date;

			  /* dias vencidos*/

			   SELECT INTO diasVencidos *
				FROM (
					 SELECT max(now()::date-(fecha_vencimiento)) as maxdia
					 FROM  con.factura fra
					 WHERE fra.dstrct = 'FINV'
						  AND fra.valor_saldo > 0
						  AND fra.reg_status = ''
						  AND fra.negasoc =reporteNegocio.negocio
						  AND fra.tipo_documento in ('FAC','NDC')
						  AND substring(documento,1,2) not in ('CP','FF','DF')
						  AND endoso_fenalco !='S'
						  AND devuelta != 'S' and corficolombiana != 'S'
					 GROUP BY negasoc

				)tabla2;

			/*valor saldo aval*/
		        SELECT into vlrSaldoAval sum(valor_saldo) FROM  con.factura fra
			 WHERE fra.negasoc = negocioAval
			  AND fra.tipo_documento in ('FAC','NDC')
			  AND fra.reg_status = ''
			  AND substring(fra.documento,1,2) not in ('CP','FF','DF')
			  AND endoso_fenalco !='S'
			  AND devuelta != 'S' and corficolombiana != 'S';


			 /*valor saldo aval vencido*/

			SELECT into vlrSaldoVencidoAval coalesce(sum(valor_saldo),0) from con.factura fra
			WHERE fra.negasoc = negocioAval
			  AND fra.tipo_documento in ('FAC','NDC')
			  AND fra.reg_status = ''
			  AND substring(fra.documento,1,2) not in ('CP','FF','DF')
			  AND endoso_fenalco !='S'
			  AND devuelta != 'S' and corficolombiana != 'S'
			  AND fra.fecha_vencimiento ::date < now()::date;



		ELSIF(negAux != reporteNegocio.negocio)THEN

		    RAISE NOTICE 'SE EJECUTA CUANDO CAMBIA DE NEGOCIO';
		/* REINICIAMOS TODAS LAS VARIABLES */
                    negAux=reporteNegocio.negocio;
		    capital_neg:=0;
		    interes_neg:=0;
		    valor_aval_neg:=0;
		    interes_aval_neg:=0;
		    VencimientoMayor:='';
		    vlrSaldo:=0;
		    vlrSaldoVencido:=0;
		    diasVencidos:=0;
		    negocioAval:='';
		    vlrSaldoAval:=0;
		    vlrSaldoVencidoAval:=0;


			/* *Buscamos capital,interes */
			SELECT INTO documentosNegAceptado SUM(capital)::numeric as capital, SUM(interes)::numeric as interes
			FROM documentos_neg_aceptado AS dnega
			WHERE dnega.cod_neg =reporteNegocio.negocio ;

			capital_neg :=documentosNegAceptado.capital;
			interes_neg :=documentosNegAceptado.interes;

			/*Buscamos negocio de aval*/
			SELECT INTO negocioAval cod_neg FROM negocios WHERE negocio_rel=reporteNegocio.negocio limit 1;
			raise notice 'negocio padre: % negocio aval %',reporteNegocio.negocio,negocioAval;

			/* *Buscamos valor aval,interes aval*/
			SELECT INTO valor_aval_neg vr_negocio FROM negocios WHERE negocio_rel= reporteNegocio.negocio ;

			SELECT INTO interes_aval_neg SUM(interes) FROM documentos_neg_aceptado AS dnega
			WHERE dnega.cod_neg = negocioAval;

			 /* *Vencimiento Mayor */

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
					 SELECT  max(now()::date-(fecha_vencimiento)) as maxdia
					 FROM  con.factura fra
					 WHERE fra.dstrct = 'FINV'
						  AND fra.valor_saldo > 0
						  AND fra.reg_status = ''
						  AND fra.negasoc =reporteNegocio.negocio
						  AND fra.tipo_documento in ('FAC','NDC')
						  AND substring(documento,1,2) not in ('CP','FF','DF')
						  AND endoso_fenalco !='S'
						  AND devuelta != 'S' and corficolombiana != 'S'
					 GROUP BY negasoc

			)tabla2;

			/*valor saldo negocio*/
		        SELECT into vlrSaldo sum(valor_saldo) FROM  con.factura fra
			 WHERE fra.negasoc = reporteNegocio.negocio
			  AND fra.tipo_documento in ('FAC','NDC')
			  AND fra.reg_status = ''
			  AND substring(fra.documento,1,2) not in ('CP','FF','DF')
			  AND endoso_fenalco !='S'
			  AND devuelta != 'S' and corficolombiana != 'S';

			 /*valor saldo negocio  vencido*/

			SELECT into vlrSaldoVencido coalesce(sum(valor_saldo),0) from con.factura fra
			WHERE fra.negasoc = reporteNegocio.negocio
			  AND fra.tipo_documento in ('FAC','NDC')
			  AND fra.reg_status = ''
			  AND substring(fra.documento,1,2) not in ('CP','FF','DF')
			  AND endoso_fenalco !='S'
			  AND devuelta != 'S' and corficolombiana != 'S'
			  AND fra.fecha_vencimiento ::date < now()::date;

			  /* dias vencidos*/

			   SELECT INTO diasVencidos *
				FROM (
					 SELECT max(now()::date-(fecha_vencimiento)) as maxdia
					 FROM  con.factura fra
					 WHERE fra.dstrct = 'FINV'
						  AND fra.valor_saldo > 0
						  AND fra.reg_status = ''
						  AND fra.negasoc =reporteNegocio.negocio
						  AND fra.tipo_documento in ('FAC','NDC')
						  AND substring(documento,1,2) not in ('CP','FF','DF')
						  AND endoso_fenalco !='S'
						  AND devuelta != 'S' and corficolombiana != 'S'
					 GROUP BY negasoc

				)tabla2;

			/*valor saldo aval*/
		        SELECT into vlrSaldoAval sum(valor_saldo) FROM  con.factura fra
			 WHERE fra.negasoc = negocioAval
			  AND fra.tipo_documento in ('FAC','NDC')
			  AND fra.reg_status = ''
			  AND substring(fra.documento,1,2) not in ('CP','FF','DF')
			  AND endoso_fenalco !='S'
			  AND devuelta != 'S' and corficolombiana != 'S';


			 /*valor saldo aval vencido*/

			SELECT into vlrSaldoVencidoAval coalesce(sum(valor_saldo),0) from con.factura fra
			WHERE fra.negasoc = negocioAval
			  AND fra.tipo_documento in ('FAC','NDC')
			  AND fra.reg_status = ''
			  AND substring(fra.documento,1,2) not in ('CP','FF','DF')
			  AND endoso_fenalco !='S'
			  AND devuelta != 'S' and corficolombiana != 'S'
			  AND fra.fecha_vencimiento ::date < now()::date;

		END IF;


		reporteNegocio.capital:=capital_neg;
		reporteNegocio.Interes :=interes_neg;
		reporteNegocio.valor_aval:=valor_aval_neg;
		reporteNegocio.Interes_aval:=interes_aval_neg;
                reporteNegocio.vencimiento_mayor :=VencimientoMayor;
		reporteNegocio.valor_saldo:=vlrSaldo;
                reporteNegocio.valor_saldo_vencido:=vlrSaldoVencido;
		reporteNegocio.dias_vencidos :=diasVencidos;
		reporteNegocio.valor_saldo_aval :=vlrSaldoAval;
		reporteNegocio.valor_saldo_aval_vencido:=vlrSaldoVencidoAval;
                reporteNegocio.negocio_aval:=negocioAval;




  -- fin super validacion

   RETURN NEXT reporteNegocio;

END LOOP;

END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_reporte_negocio_automotor()
  OWNER TO postgres;
