-- Function: eg_saldos_reestructuracion_fenalco_con_fecha(character varying, character varying, date)

-- DROP FUNCTION eg_saldos_reestructuracion_fenalco_con_fecha(character varying, character varying, date);

CREATE OR REPLACE FUNCTION eg_saldos_reestructuracion_fenalco_con_fecha(codigo_neg character varying, distrito character varying, fecha_corte date)
  RETURNS SETOF record AS
$BODY$
DECLARE

  listaFacturas record;
  saldoInteres numeric;
  saldoCapital numeric;
  restoAplicacionInt numeric;

  sumaConceptos numeric;
  tasaIm record;
  ixmItem numeric;
  gacItem numeric;
  sumaSaldo numeric;
  fechaAnterior date;
  resta numeric;

  unidadNegocio integer;
  porGaC numeric;
  nuevoInteres numeric;
  diasInteresCorriente numeric;


BEGIN

   SELECT INTO fechaAnterior fecha_negocio FROM negocios WHERE cod_neg= codigo_neg;
   FOR listaFacturas IN (
			SELECT   fac.documento::varchar as documento,
				 fac.negasoc::varchar as negocio,
				 fac.num_doc_fen::varchar as cuota,
				 fac.fecha_vencimiento ::date as fecha_vencimiento,
				 (fecha_corte::date-(fac.fecha_vencimiento))::numeric as dias_mora,
                                 ''::varchar as estado,
                                 eg_tipo_negocio(fac.negasoc)::varchar as tipo_negocio,
				 fac.valor_factura::numeric,
		                 fac.valor_abono::numeric,
				 fac.valor_saldo::numeric,
				 (fac.valor_factura - facdet.valor_unitario)::numeric as valor_unitario_capital,
				 facdet.valor_unitario::numeric as valor_unitario_interes,
				 0::numeric as valor_saldo_capital,
				 0::numeric as valor_saldo_interes,
				 0::numeric as IxM,
				 0::numeric as GaC,
				 0::numeric as suma_saldos
			FROM con.factura as fac
			LEFT JOIN con.factura_detalle as facdet on (fac.documento=facdet.documento)
			WHERE fac.negasoc =codigo_neg
			AND substring(fac.documento,1,2) not in ('CP','FF','DF')
			AND fac.dstrct=distrito AND facdet.dstrct=distrito
			AND valor_saldo > 0
			AND fac.reg_status !='A'
			--AND facdet.descripcion in ('INTERESES','AVAL','PG','CH') --OR facdet.descripcion IN ('CAPITAL'))
			AND facdet.reg_status !='A'
                        AND CASE WHEN ((select count(0) from con.factura_detalle where documento = fac.documento) = 1 AND substring(fac.documento,1,2) in ('AP','AC')) THEN
					facdet.descripcion IN ('CAPITAL','PG','CH','INTERESES','AVAL','BQ-014-FENALCO-OTROS  INTERESES')
				ELSE facdet.descripcion in ('INTERESES','AVAL','PG','CH')
				END
			order by  fac.negasoc,fac.num_doc_fen::numeric
			)
	LOOP
	        saldoInteres=0;
		saldoCapital=0;
		restoAplicacionInt:=0;
		sumaConceptos=0;
                --tasaIm=0;

                ixmItem=0;
                gacItem:=0;
                sumaSaldo=0;
		resta=0;
                diasInteresCorriente= 0;

		IF (listaFacturas.dias_mora > 0) THEN

			/* ***********************
			* Estado de la factura   *
			**************************/
			listaFacturas.estado='VENCIDO';

                        /* *************************************************************
			* Calculamos el saldo para los intereses y capital por cuota   *
			****************************************************************/
			restoAplicacionInt:=listaFacturas.valor_unitario_interes - listaFacturas.valor_abono;

			  IF(restoAplicacionInt >= 0)THEN
			     saldoInteres:=restoAplicacionInt;
			     saldoCapital:=listaFacturas.valor_unitario_capital;
                          ELSE
			     saldoInteres:=0;
			     restoAplicacionInt:=(restoAplicacionInt * -1);
			     saldoCapital:=listaFacturas.valor_unitario_capital - restoAplicacionInt;
                          END IF;

                         /* ***VALIDAMOS SI EL NEGOCIO ES NG ****
                         *****************************************/
                         IF(SUBSTRING(codigo_neg,1,2)='NG')THEN
			    saldoCapital:=listaFacturas.valor_unitario_interes-listaFacturas.valor_abono;
                            saldoInteres:=0;
                         END IF;

			/* ****VALIDAMOS LA CUOTA 00 SI TIENE ****
                        *****************************************/
			IF(SUBSTRING(listaFacturas.documento,8,2)='00')THEN
			     raise notice 'listaFacturas.documento 00 vencido %',listaFacturas.documento;
			     saldoCapital:=listaFacturas.valor_saldo;
			     saldoInteres:=0;
			END IF;

			/* ****VALIDAMOS DOCUMENTOS AP, AC SIN CONCEPTO DE INTERES *****
                        ****************************************************************/
			IF(((select count(0) from con.factura_detalle where documento = listaFacturas.documento) = 1 AND substring(listaFacturas.documento,1,2) in ('AP','AC')))THEN
			     raise notice 'listaFacturas.documento AP, AC SIN CONCEPTO DE INTERES %',listaFacturas.documento;
			     saldoCapital:=listaFacturas.valor_saldo;
			     saldoInteres:=0;
			END IF;


                        listaFacturas.valor_saldo_capital:=saldoCapital;
                        listaFacturas.valor_saldo_interes:=saldoInteres;

                         RAISE NOTICE 'saldoInteres = %  restoAplicacionInt = %',saldoInteres,restoAplicacionInt;
                         RAISE NOTICE 'saldoCapital = % ',saldoCapital;

		       /* *********************************************
			* Sumar conceptos : saldoCapital+saldoInteres *
			***********************************************/
			sumaConceptos :=saldoCapital+saldoInteres;

			/* *******************************************
			* Buscamos tasa del negocio. por el convenio *
			**********************************************/
			IF(sumaConceptos = listaFacturas.valor_saldo)THEN

				SELECT INTO tasaIm c.tasa_interes,c.id_convenio FROM negocios as n
				INNER JOIN convenios as c on (c.id_convenio=n.id_convenio)
				WHERE n.cod_neg =listaFacturas.negocio;

					IF (FOUND) THEN

					ixmItem := round((((sumaConceptos * tasaIm.tasa_interes)/100 ) / 30) * listaFacturas.dias_mora );
					listaFacturas.IxM := ixmItem;

					END IF;

				RAISE NOTICE 'Interes Mora = % ',ixmItem;

				SELECT INTO unidadNegocio id_unid_negocio FROM rel_unidadnegocio_convenios where id_convenio in (tasaIm.id_convenio) and id_unid_negocio in (1,2,3,4,8,10);

				SELECT INTO porGaC coalesce(porcentaje,'0') FROM sanciones_condonaciones
				WHERE id_tipo_acto = 1 AND id_unidad_negocio  =  unidadNegocio
				AND periodo = replace(substring(now(),1,7),'-','')::numeric AND listaFacturas.dias_mora BETWEEN dias_rango_ini AND dias_rango_fin
				AND categoria = 'GAC' group by porcentaje,dias_rango_ini,dias_rango_fin;

				IF FOUND THEN
					RAISE NOTICE 'porcentaje = % ',porGaC;
					gacItem := ROUND((sumaConceptos * porGaC::numeric)/100);
					listaFacturas.GaC := gacItem;
                                ELSE
                                 gacItem:=0;
                                 listaFacturas.GaC := gacItem;
				END IF;
			END IF;



                         /* *****************
			 ** Suma saldos *****
			 *********************/
			sumaSaldo = sumaConceptos + ixmItem + gacItem;
			listaFacturas.suma_saldos=sumaSaldo;

			RAISE NOTICE 'sumaSaldo = %',sumaSaldo;

			fechaAnterior =listaFacturas.fecha_vencimiento;



		ELSE

		    /* ***********************
		     * Estado de la factura   *
		     **************************/
		     listaFacturas.estado='CORRIENTE';

		    /* ***********************************************
		     * Verificamos si es la primera cuaota corriente *
		     * Despues de la vencidas                        *
		     *************************************************/

		     resta= listaFacturas.fecha_vencimiento - fechaAnterior;

			IF(resta between 27  and 34)THEN --esta condicion solo me sirve para saber cual es al cuota
			    raise notice 'my hoy - fecha vencimiento anterior %',(now()::date-fechaAnterior::date);

			    diasInteresCorriente:=now()::date-fechaAnterior::date;
			    IF(diasInteresCorriente > 30) THEN diasInteresCorriente:=30; END IF;

                             nuevoInteres:=ROUND((listaFacturas.valor_unitario_interes/30)*(diasInteresCorriente));
                             saldoInteres:=nuevoInteres;

			END IF;

		        /* ***VALIDAMOS SI EL NEGOCIO ES NG ****
                         *****************************************/
                         IF(SUBSTRING(codigo_neg,1,2)='NG')THEN
			    saldoCapital:=listaFacturas.valor_unitario_interes-listaFacturas.valor_abono;
                         ELSE

			    IF(listaFacturas.valor_abono>0 AND (listaFacturas.valor_unitario_capital-listaFacturas.valor_saldo) > 0 )THEN
				saldoCapital:= listaFacturas.valor_saldo;
			    ELSE
                              saldoCapital:=listaFacturas.valor_unitario_capital;
                            END IF;

                        END IF;

			/* ****VALIDAMOS LA CUOTA 00 SI TIENE ****
                        *****************************************/
			IF(SUBSTRING(listaFacturas.documento,8,2)='00')THEN
				raise notice 'listaFacturas.documento 00 %',listaFacturas.documento;
				saldoCapital:=listaFacturas.valor_saldo;
				saldoInteres:=0;
			END IF;

				/* ****VALIDAMOS DOCUMENTOS AP, AC SIN CONCEPTO DE INTERES *****
                        ****************************************************************/
			IF(((select count(0) from con.factura_detalle where documento = listaFacturas.documento) = 1 AND substring(listaFacturas.documento,1,2) in ('AP','AC')))THEN
			     raise notice 'listaFacturas.documento AP, AC SIN CONCEPTO DE INTERES %',listaFacturas.documento;
			     saldoCapital:=listaFacturas.valor_saldo;
			     saldoInteres:=0;
			END IF;



                     listaFacturas.valor_saldo_interes:=saldoInteres;
		     listaFacturas.valor_saldo_capital:=saldoCapital;
                     --listaFacturas.valor_saldo_capital:=listaFacturas.valor_unitario_capital;

		      sumaSaldo := saldoCapital + saldoInteres;
                      listaFacturas.suma_saldos=sumaSaldo;
		END IF;


	RETURN NEXT listaFacturas;

   END LOOP;

END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_saldos_reestructuracion_fenalco_con_fecha(character varying, character varying, date)
  OWNER TO postgres;
