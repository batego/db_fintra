-- Function: eg_saldos_reestructuracion_negocios(character varying)

-- DROP FUNCTION eg_saldos_reestructuracion_negocios(character varying);

CREATE OR REPLACE FUNCTION eg_saldos_reestructuracion_negocios(cod_neg character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE
  listaFacturas record;
  filaLiquidador record;
  saldoMI numeric;
  saldoCA numeric;
  sumaConceptos numeric;
  tasaIm numeric;
  tasaIg numeric;
  ixmItem numeric;
  gacItem numeric;
  sumaSaldo numeric;
  fechaAnterior date;
  resta numeric;


BEGIN

   FOR listaFacturas IN (

			SELECT   fac.documento::varchar as documento,
				 fac.negasoc::varchar as negocio,
				 fac.num_doc_fen::varchar as cuota,
				 fac.fecha_vencimiento ::date as fecha_vencimiento,
				 (now()::date-(fac.fecha_vencimiento))::numeric as dias_mora,
				 ''::varchar as estado,
				 fac.valor_saldo - facdet.valor_unitario ::numeric as valor_saldo_capital,
				 0::numeric as valor_saldo_mi,
				 0::numeric as valor_saldo_ca,
				 facdet.valor_unitario ::numeric as valor_seguro,
				 0::numeric as IxM,
				 0::numeric as GaC,
				 0::numeric as suma_saldos

			FROM con.factura as fac
			INNER JOIN con.factura_detalle as facdet on (fac.documento=facdet.documento)
			WHERE fac.negasoc= cod_neg
			AND fac.documento LIKE 'MC%'
			AND valor_saldo > 0
			AND fac.reg_status !='A'
			AND facdet.descripcion='SEGURO'
			order by  fac.num_doc_fen::numeric
			)
	LOOP
	        saldoMI=0;
		saldoCA=0;
		sumaConceptos=0;
                tasaIm=0;
		tasaIg=0;
                ixmItem=0;
                gacItem=0;
                sumaSaldo=0;
		resta=0;

		IF (listaFacturas.dias_mora > 0) THEN

			/* ***********************
			* Estado de la factura   *
			**************************/
			listaFacturas.estado='VENCIDO';

                        /* ******************************************************
			* buscamos el saldo de  la cuota en iterada facturas MI *
			*********************************************************/

			SELECT INTO saldoMI coalesce(sum(valor_saldo),0) FROM con.factura fac
			WHERE  fac.negasoc= listaFacturas.negocio
			AND fac.num_doc_fen= listaFacturas.cuota
			AND fac.documento LIKE 'MI%'
			AND valor_saldo > 0
			AND fac.reg_status !='A' ;

				IF (FOUND) THEN

				  listaFacturas.valor_saldo_mi=	saldoMI;

				END IF;

		       /* ******************************************************
			* buscamos el saldo de la cuota en iterada facturas CA *
			*******************************************************/

			SELECT INTO saldoCA coalesce(sum(valor_saldo),0) FROM con.factura fac
			WHERE  fac.negasoc= listaFacturas.negocio
			AND fac.num_doc_fen= listaFacturas.cuota
			AND fac.documento LIKE 'CA%'
			AND valor_saldo > 0
			AND fac.reg_status !='A' ;

				IF (FOUND) THEN

				  listaFacturas.valor_saldo_ca=	saldoCA;
					RAISE NOTICE 'suma conceptaos %',saldoCA;

				END IF;

		       /* ********************************************************
			* Calcular sanciones :  Suma CAPs + MIs + CAs , IxM, GaC *
			**********************************************************/
			sumaConceptos=listaFacturas.valor_saldo_capital+ listaFacturas.valor_seguro + saldoMI + saldoCA ;

			/* *******************************************
			* Buscamos tasa del negocio. por el convenio *
			**********************************************/

			SELECT INTO tasaIm c.tasa_interes FROM negocios as n
			INNER JOIN convenios as c on (c.id_convenio=n.id_convenio)
			WHERE n.cod_neg =listaFacturas.negocio;

				IF (FOUND) THEN

				/* *******************************
				* Calculamos el interes por mora *
				**********************************/

				ixmItem = round((((sumaConceptos * tasaIm)/100 ) / 30) * listaFacturas.dias_mora );
				listaFacturas.IxM = ixmItem;

				END IF;

			/* *******************************
			* Gastos de Cobranza por factura *
			**********************************/

			SELECT INTO tasaIg max(porcentaje) FROM sanciones_condonaciones
			WHERE id_unidad_negocio = 1
			AND id_conceptos_recaudo in (2,4,6)
			AND id_tipo_acto = 1
			AND categoria='GAC'
			AND periodo = replace(substring(now(),1,7),'-','')
			AND listaFacturas.dias_mora between dias_rango_ini and dias_rango_fin
                        GROUP BY id_conceptos_recaudo
			ORDER by id_conceptos_recaudo ;


				IF (FOUND) THEN

				/* *******************************
				* Calculamos el Gasto de cobranza *
				**********************************/
				gacItem=round((sumaConceptos * tasaIg) ::numeric /100) ;

				listaFacturas.GaC = gacItem;


				END IF;

                         /* *****************
			 ** Suma saldos *****
			 *********************/

			sumaSaldo = sumaConceptos + ixmItem +gacItem ;

			listaFacturas.suma_saldos=sumaSaldo;

			fechaAnterior =listaFacturas.fecha_vencimiento;



		ELSE

		    /* ***********************
		     * Estado de la factura   *
		     **************************/
		     listaFacturas.estado='CORRIENTE';


                    SELECT INTO filaLiquidador * FROM documentos_neg_aceptado d   where d.cod_neg=listaFacturas.negocio and d.item =listaFacturas.cuota ;

		    /* ***********************************************
		     * Verificamos si es la primera cuaota corriente *
		     * Despues de la vencidas                        *
		     *************************************************/
		     resta= listaFacturas.fecha_vencimiento - fechaAnterior;

			IF(resta between 29  and 34)THEN
                                saldoMI=filaLiquidador.interes;
				listaFacturas.valor_saldo_mi= saldoMI;
			END IF;

		      listaFacturas.valor_saldo_ca=filaLiquidador.cat;

                     /* ******************************
                      * Ponemos valor seguro en cero *
                      ********************************/

			listaFacturas.valor_seguro=0;

		      sumaSaldo= listaFacturas.valor_saldo_capital + saldoMI + filaLiquidador.cat;
                      listaFacturas.suma_saldos=sumaSaldo;
		END IF;


	RETURN NEXT listaFacturas;

   END LOOP;

END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_saldos_reestructuracion_negocios(character varying)
  OWNER TO postgres;
