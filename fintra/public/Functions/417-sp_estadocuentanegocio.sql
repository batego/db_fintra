-- Function: sp_estadocuentanegocio(character varying)

-- DROP FUNCTION sp_estadocuentanegocio(character varying);

CREATE OR REPLACE FUNCTION sp_estadocuentanegocio(cod_neg character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE

	listaFacturas record;
	tasaIm record;

	_PeriodoActual varchar;

	saldoInteres numeric;
	saldoCapital numeric;
	restoAplicacionInt numeric;
	sumaConceptos numeric;
	ixmItem numeric;
	gacItem numeric;
	sumaSaldo numeric;
	resta numeric;
	porGaC numeric;
	nuevoInteres numeric;

	unidadNegocio integer;

	fechaAnterior date;
	miHoy date;

BEGIN


	miHoy = now()::date;


	_PeriodoActual = replace(substring(miHoy,1,7),'-','')::varchar;

	FOR listaFacturas IN

		SELECT  fac.documento::varchar as documento,
			fac.negasoc::varchar as negocio,
			fac.num_doc_fen::varchar as cuota,
			fac.fecha_vencimiento ::date as fecha_vencimiento,
			(now()::date-(fac.fecha_vencimiento))::numeric as dias_mora,
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
		INNER JOIN con.factura_detalle as facdet on (fac.documento=facdet.documento)
		WHERE fac.negasoc =cod_neg
		AND substring(fac.documento,1,2) not in ('CP','FF','DF')
		AND valor_saldo > 0
		AND fac.reg_status !='A'
		AND facdet.descripcion in ('INTERESES','AVAL','PG','CH')
		AND facdet.reg_status !='A'
		AND replace(substring(fac.fecha_vencimiento,1,7),'-','') <= _PeriodoActual
		--AND fac.fecha_vencimiento <= now()::date
		order by  fac.negasoc,fac.num_doc_fen::numeric

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

                --VENCIDO
		IF (listaFacturas.dias_mora > 0) THEN

			/* Estado de la factura */
			listaFacturas.estado='VENCIDO';

                        /* Calculamos el saldo para los intereses y capital por cuota */
			restoAplicacionInt:=listaFacturas.valor_unitario_interes - listaFacturas.valor_abono;

			IF(restoAplicacionInt >= 0)THEN

				saldoInteres:=restoAplicacionInt;
				saldoCapital:=listaFacturas.valor_unitario_capital;
			ELSE
				saldoInteres:=0;
				restoAplicacionInt:=(restoAplicacionInt * -1);
				saldoCapital:=listaFacturas.valor_unitario_capital - restoAplicacionInt;
			END IF;


                        /* VALIDAMOS SI EL NEGOCIO ES NG */
                        IF(SUBSTRING(cod_neg,1,2)='NG')THEN
				saldoCapital:=listaFacturas.valor_unitario_interes-listaFacturas.valor_abono;
				saldoInteres:=0;
                        END IF;

                        listaFacturas.valor_saldo_capital:=saldoCapital;
                        listaFacturas.valor_saldo_interes:=saldoInteres;

                        RAISE NOTICE 'saldoInteres = %  restoAplicacionInt = %',saldoInteres,restoAplicacionInt;
                        RAISE NOTICE 'saldoCapital = % ',saldoCapital;

		        /* Sumar conceptos : saldoCapital+saldoInteres */
			sumaConceptos :=saldoCapital+saldoInteres;

			/* Buscamos tasa del negocio. por el convenio */
			IF(sumaConceptos = listaFacturas.valor_saldo)THEN

				SELECT INTO tasaIm c.tasa_interes,c.id_convenio
				FROM negocios as n
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

                        /* Suma saldos */
			sumaSaldo = sumaConceptos + ixmItem + gacItem;
			listaFacturas.suma_saldos=sumaSaldo;

			RAISE NOTICE 'sumaSaldo = %',sumaSaldo;

			fechaAnterior =listaFacturas.fecha_vencimiento;

		--CORRIENTE
		ELSE

			/* Estado de la factura */
			listaFacturas.estado='CORRIENTE';

			/* ***********************************************
			* Verificamos si es la primera cuaota corriente *
			* Despues de la vencidas                        *
			*************************************************/
			resta= listaFacturas.fecha_vencimiento - fechaAnterior;

			IF(resta between 27  and 34)THEN --esta condicion solo me sirve para saber cual es al cuota
			    raise notice 'my hoy - fecha vencimiento anterior %',(now()::date-fechaAnterior::date);
                             nuevoInteres:=ROUND((listaFacturas.valor_unitario_interes/30)*(now()::date-fechaAnterior::date));
                             saldoInteres:=nuevoInteres;

			END IF;

		        /* VALIDAMOS SI EL NEGOCIO ES NG */
                        IF(SUBSTRING(cod_neg,1,2)='NG')THEN
				saldoCapital:=listaFacturas.valor_unitario_interes-listaFacturas.valor_abono;
                        ELSE
				saldoCapital:=listaFacturas.valor_unitario_capital;
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
ALTER FUNCTION sp_estadocuentanegocio(character varying)
  OWNER TO postgres;
