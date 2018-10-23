-- Function: sp_reporte_cartera_fianza_libranza(integer, character varying)

-- DROP FUNCTION sp_reporte_cartera_fianza_libranza(integer, character varying);

CREATE OR REPLACE FUNCTION sp_reporte_cartera_fianza_libranza(_linea_negocio integer, _empresa_fianza character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE
listaNegocios record;
listaFacturas record;
saldoFactura numeric;
saldoInteres numeric;
saldoCAT numeric;
saldoCapital numeric;
saldoMI numeric;
saldoCA numeric;
valorSeguro numeric;
sumaConceptos numeric;
tasaIm numeric;
tasaIg numeric;
ixmItem numeric;
gacItem numeric;
total_mi numeric;
total_ca numeric;
total_ixm numeric;
total_gac numeric;
sumaSaldo numeric;
fechaAnterior date;
resta numeric;
_periodo_foto character varying;
_inicialDoc character varying;
_interesFac numeric;
_total_interes numeric;

BEGIN

   --SELECT INTO  _periodo_foto substring(replace((to_date(_periodo_corte,'YYYYMMDD')  + interval '1 month')::date,'-',''),1,6);
     SELECT INTO  _periodo_foto substring(replace(now()::date,'-',''),1,6);

   FOR listaNegocios IN ((
			    SELECT ctrl.nit_cliente AS id_cliente,
			    num_pagare::varchar AS num_pagare,
			    negocio AS num_credito,
			    0::numeric AS vlr_capital,
			    0::numeric AS interes_corriente,
			    0::numeric AS interes_mora,
			    replace(ctrl.fecha_vencimiento::date,'-','')::varchar AS fecha_corte
			    FROM administrativo.historico_deducciones_fianza ctrl
			    INNER JOIN negocios neg ON neg.cod_neg = ctrl.negocio
			    WHERE ctrl.id_unidad_negocio = _linea_negocio and estado_neg !='R'
			    --AND periodo_corte = _periodo_corte
			    and (replace((substring (neg.f_desem,1,7)),'-',''))::numeric <=	(replace((substring ((now() -interval '2 Month'),1,7)),'-',''))::numeric
			    AND nit_empresa_fianza = _empresa_fianza AND estado_proceso IN ('P','')
			    GROUP BY ctrl.nit_cliente, num_pagare, negocio, fecha_vencimiento
                            ORDER BY negocio)
				union all
				(
				SELECT ctrl.nit_cliente AS id_cliente,
				num_pagare::varchar AS num_pagare,
				negocio AS num_credito,
				0::numeric AS vlr_capital,
				0::numeric AS interes_corriente,
				0::numeric AS interes_mora,
				replace(ctrl.fecha_vencimiento::date,'-','')::varchar AS fecha_corte
				FROM administrativo.historico_deducciones_fianza ctrl
				INNER JOIN negocios neg ON neg.cod_neg = ctrl.negocio
				WHERE ctrl.id_unidad_negocio = _linea_negocio
				and negocio in ('LB00525','LB00527') and estado_neg !='R'
				AND nit_empresa_fianza = _empresa_fianza AND estado_proceso IN ('P','')
				GROUP BY ctrl.nit_cliente, num_pagare, negocio, fecha_vencimiento
				ORDER BY negocio
				)
                        )
	LOOP

	  saldoInteres :=0;
	  saldoCAT :=0;
          valorSeguro :=0;

          saldoCapital :=0;
          total_mi :=0;
	  total_ca :=0;
	  total_ixm :=0;
	  total_gac :=0;

	  SELECT  INTO saldoFactura    coalesce(sum(valor_saldo),0) FROM con.foto_cartera foto
					WHERE  foto.negasoc= listaNegocios.num_credito
					AND foto.documento LIKE 'LC%'
					AND valor_saldo > 0
					AND foto.periodo_lote = _periodo_foto
					AND foto.reg_status !='A' ;

          SELECT INTO saldoInteres coalesce(sum(interes),0) FROM documentos_neg_aceptado
	  WHERE cod_neg = listaNegocios.num_credito
	  AND fecha::date <= (sp_fecha_corte_foto(substring(_periodo_foto,1,4),substring(_periodo_foto,5,6)::int)::date)::date;

          SELECT INTO saldoCAT coalesce(sum(cat),0) FROM documentos_neg_aceptado
	  WHERE cod_neg = listaNegocios.num_credito;

	  SELECT INTO valorSeguro seguro FROM documentos_neg_aceptado
	  WHERE cod_neg = listaNegocios.num_credito
          GROUP BY seguro;

	  RAISE NOTICE 'valorSeguro %',valorSeguro;

        --RAISE NOTICE 'saldoCAT %',saldoCAT;

	--RAISE NOTICE 'negocio %',listaNegocios.num_credito;
	        FOR listaFacturas IN(select     foto.negasoc as negocio,
						foto.documento::varchar as documento,
						foto.num_doc_fen::varchar as cuota,
						foto.fecha_vencimiento ::date as fecha_vencimiento,
						((sp_fecha_corte_foto(substring(_periodo_foto,1,4),substring(_periodo_foto,5,6)::int)::date)::date-foto.fecha_vencimiento::date)::int as dias_mora,
						foto.valor_factura::numeric as valor_factura,
                                                facdet.valor_unitario::numeric as valor_saldo_capital,
						facdetseg.valor_unitario::numeric AS valor_seguro,
						0::numeric as interes_factura,
						0::numeric as IxM,
						0::numeric as GaC,
						0::numeric as total_saldo
					FROM con.foto_cartera as foto
					INNER JOIN con.factura_detalle facdet ON(facdet.documento = foto.documento and facdet.descripcion =  'CAPITAL')
					INNER JOIN con.factura_detalle facdetseg ON(facdetseg.documento = foto.documento and facdetseg.descripcion =  'SEGURO')
					WHERE foto.negasoc= listaNegocios.num_credito
					AND foto.documento LIKE 'LC%'
					AND foto.periodo_lote = _periodo_foto
					AND valor_saldo > 0
					AND foto.reg_status !='A'
                                        order by foto.num_doc_fen::numeric) LOOP

                                        saldoMI=0;
					saldoCA=0;
					sumaConceptos=0;
					tasaIm=0;
					tasaIg=0;
					ixmItem=0;
					gacItem=0;
					sumaSaldo=0;
					resta=0;

					--no se le resta listaFacturas.valor_seguro ya que libranza no tiene seguro
					saldoCapital = saldoCapital + listaFacturas.valor_saldo_capital;


			       /* ******************************************************
				* buscamos el saldo de la cuota en iterada facturas  *
				*******************************************************/

				SELECT into _interesFac coalesce(sum(valor_saldo),0) FROM con.factura fac
				inner join con.factura_detalle det on (fac.documento = det.documento )
				WHERE  fac.negasoc= listaFacturas.negocio
				and det.descripcion = 'INTERES'
				AND fac.num_doc_fen= listaFacturas.cuota
				AND fac.documento LIKE 'LC%'
				AND valor_saldo > 0
				AND fac.reg_status !='A' ;

					IF (FOUND) THEN

						listaFacturas.interes_factura = _interesFac;
						_total_interes = _total_interes + _interesFac;

					END IF;

                        /* *********************************************************/

			sumaConceptos=listaFacturas.valor_saldo_capital + _interesFac;
			RAISE NOTICE 'sumaConceptos %',sumaConceptos;

			--VALIDAMOS QUE LA FACTURA ESTE VENCIDA PARA REALIZAR CALCULO DE IXM Y GAC
			IF (listaFacturas.dias_mora > 0) THEN
			        RAISE NOTICE 'Dias Mora %',listaFacturas.dias_mora;
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

					total_ixm = total_ixm + ixmItem;

					END IF;
                                        RAISE NOTICE 'IXM %',ixmItem;

					/* *******************************
					* Gastos de Cobranza por factura *
					**********************************/

					SELECT INTO tasaIg max(porcentaje)
					FROM sanciones_condonaciones
					WHERE id_unidad_negocio = _linea_negocio
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
		                                total_gac = total_gac + gacItem;

					        END IF;
					        RAISE NOTICE 'GAC %',gacItem;
			END IF;

		END LOOP;

		        listaNegocios.vlr_capital = saldoCapital;
			--Si el negocio esta pago, no debe generar intereses
		        IF(listaNegocios.vlr_capital = 0) THEN
				listaNegocios.interes_corriente = 0;
			ELSE
				listaNegocios.interes_corriente = saldoInteres;
			END IF;

		        --listaNegocios.interes_corriente = saldoInteres;
			listaNegocios.interes_mora = listaNegocios.interes_mora	+ total_ixm;

        RETURN NEXT listaNegocios;

   END LOOP;

END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_reporte_cartera_fianza_libranza(integer, character varying)
  OWNER TO postgres;
