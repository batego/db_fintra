-- Function: sp_det_facturas_indemnizar_fianza_micro(character varying, character varying, integer, character varying, integer, character varying, boolean, boolean)

-- DROP FUNCTION sp_det_facturas_indemnizar_fianza_micro(character varying, character varying, integer, character varying, integer, character varying, boolean, boolean);

CREATE OR REPLACE FUNCTION sp_det_facturas_indemnizar_fianza_micro(_negocio character varying, periodo_corte character varying, _linea_negocio integer, _empresa_fianza character varying, _mora integer, filtro character varying, acelerar_pagare boolean, _gac boolean)
  RETURNS SETOF record AS
$BODY$
DECLARE
  listaFacturas record;
  listaFacturasVenc record;
  facturasVencidas record;
  filaLiquidador record;
  saldoMI numeric;
  saldoCA numeric;
  sumaConceptos numeric;
  saldoMIV numeric;
  saldoCAV numeric;
  sumaConceptosV numeric;
  tasaIm numeric;
  tasaIg numeric;
  ixmItem numeric;
  gacItem numeric;
  sumaSaldo numeric;
  fechaAnterior date;
  resta numeric;
  diasInteresCorriente numeric;
  nuevoInteres numeric;
  SQL TEXT;
  SQLResult TEXT;
  result TEXT;
  _detalleSaldoFacturas record;
   result_var record;


BEGIN

   DELETE FROM tem.facturas_indemnizar_fianza_micro;

    --Query que trae las cuotas vencidas para un vencimiento y filtro dado
    SQL:= 'SELECT
		    un.descripcion as nombre_linea_negocio,
		    foto.codcli,
		    nit::varchar as nit_cliente,
		    get_nombc(foto.nit)::varchar as nombre_cliente,
		    periodo_lote as periodo_foto,
		    negasoc as negocio,
		    coalesce(neg.num_pagare,'''')::varchar as num_pagare,
		    foto.documento,
		    foto.num_doc_fen as cuota,
		    foto.fecha_vencimiento::date,
		    (sp_fecha_corte_foto(substring(periodo_lote,1,4),substring(periodo_lote,5,6)::int)::date-foto.fecha_vencimiento::date)::int as dias_mora,
		    foto.valor_factura::numeric as valor_factura,
		    foto.valor_saldo::numeric as valor_saldo_capital,
		    0.00::numeric as valor_desistir,
		    ''0099-01-01''::date as fecha_indemnizacion,
		    0::numeric as valor_saldo_mi,
		    0::numeric as valor_saldo_ca,
		    0::numeric as valor_saldo_cm,
		    0::numeric as IxM,
		    0::numeric as GaC,
		    0::numeric as total_saldo,
		    foto.id_convenio::int as convenio,
		    cmc.cuenta,
		    un.ref_4,
		    ''''::varchar as cartera_en,
		    ''VENCIDO''::VARCHAR AS estado
	       FROM con.foto_cartera foto
	       INNER join negocios AS neg on (neg.cod_neg=foto.negasoc and neg.estado_neg IN (''T'',''A''))
	       INNER JOIN solicitud_aval AS s ON (s.cod_neg=neg.cod_neg) AND s.reg_status=''''
	       INNER join rel_unidadnegocio_convenios as run on (run.id_convenio=foto.id_convenio)
	       INNER join unidad_negocio AS un on (run.id_unid_negocio=un.id)
	       INNER JOIN con.cmc_doc AS cmc on (cmc.cmc=foto.cmc and cmc.tipodoc=foto.tipo_documento)
	       INNER join administrativo.historico_deducciones_fianza as  df on (df.negocio =neg.cod_neg)
	       LEFT join administrativo.control_indemnizacion_fianza as  ctrl on (ctrl.documento=foto.documento and ctrl.negocio =foto.negasoc )
	       WHERE periodo_lote='|| periodo_corte ||
	       ' AND foto.reg_status='''' AND foto.dstrct =''FINV''
	         AND substring(foto.documento,1,2) NOT IN (''AP'',''AC'',''R0'',''FF'',''CP'',''PF'',''MI'',''CA'')
		 AND foto.valor_saldo > 0
	         AND s.fianza = ''S''
	         AND foto.negasoc='''|| _negocio ||'''
	         AND ctrl.documento is null
	         AND (sp_fecha_corte_foto(substring(periodo_lote,1,4),substring(periodo_lote,5,6)::int)::date-foto.fecha_vencimiento::date) between 1 and '|| _mora ||
	       ' AND un.id =' || _linea_negocio ||  filtro ||
	       ' AND df.nit_empresa_fianza =' || _empresa_fianza ||'
		--#filtmonto
		ORDER BY foto.negasoc,foto.documento, foto.num_doc_fen;';

	-- AND (sp_fecha_corte_foto(substring(periodo_lote,1,4),substring(periodo_lote,5,6)::int)::date-foto.fecha_vencimiento::date)  > '|| _mora ||
	RAISE INFO 'SQL %',SQL;
       FOR result_var IN EXECUTE SQL LOOP

         --INSERTA LAS FACTURAS VENCIDAS DEL NEGOCIO.
         RAISE INFO 'result_var: %',result_var;
         INSERT INTO tem.facturas_indemnizar_fianza_micro
         VALUES(result_var.nombre_linea_negocio,result_var.codcli,result_var.nit_cliente,result_var.nombre_cliente,result_var.periodo_foto,result_var.negocio,result_var.num_pagare,
         result_var.documento,result_var.cuota,result_var.fecha_vencimiento,result_var.dias_mora,result_var.valor_factura,result_var.valor_saldo_capital,result_var.valor_desistir,
         result_var.fecha_indemnizacion,result_var.valor_saldo_mi,result_var.valor_saldo_ca,result_var.IxM,result_var.GaC,result_var.total_saldo,result_var.convenio,result_var.cuenta,
         result_var.ref_4,result_var.cartera_en,result_var.estado, result_var.valor_saldo_cm);

       END LOOP ;

       IF(acelerar_pagare)THEN
	       FOR facturasVencidas IN(
	                               SELECT periodo_foto, negocio, num_pagare, convenio, nombre_linea_negocio, ref_4
	                               FROM tem.facturas_indemnizar_fianza_micro
	                               GROUP BY periodo_foto, negocio, num_pagare, convenio, nombre_linea_negocio, ref_4
	                               )
	       LOOP
			--BUSCA LAS FACTURAS FUTURAS DEL NEGOCIO.
	                RAISE NOTICE 'Negocio %',facturasVencidas.negocio;
                        INSERT INTO tem.facturas_indemnizar_fianza_micro
                        SELECT
                                facturasVencidas.nombre_linea_negocio,
                                foto.codcli,
				foto.nit::varchar as nit_cliente,
                                get_nombc(foto.nit)::varchar as nombre_cliente,
                                facturasVencidas.periodo_foto,
                                foto.negasoc as negocio,
				coalesce(facturasVencidas.num_pagare,'')::varchar as num_pagare,
                                foto.documento::varchar as documento,
				foto.num_doc_fen::varchar as cuota,
				foto.fecha_vencimiento ::date as fecha_vencimiento,
				(sp_fecha_corte_foto(substring(periodo_corte,1,4),substring(periodo_corte,5,6)::int)::date-foto.fecha_vencimiento::date)::int as dias_mora,
				foto.valor_factura::numeric as valor_factura,
				foto.valor_saldo::numeric as valor_saldo_capital,
				0.00::numeric as valor_desistir,
				'0099-01-01'::date as fecha_indemnizacion,
				 0::numeric as valor_saldo_mi,
				 0::numeric as valor_saldo_ca,
				 0::numeric as IxM,
				 0::numeric as GaC,
				 0::numeric as total_saldo,
				facturasVencidas.convenio::int as convenio,
				cmc.cuenta,
				facturasVencidas.ref_4,
				''::varchar as cartera_en,
                                (CASE WHEN ((sp_fecha_corte_foto(substring(periodo_corte,1,4),substring(periodo_corte,5,6)::int)::date-foto.fecha_vencimiento::date)::int>0) THEN 'VENCIDO' ELSE 'FUTURA' END)::varchar as estado,
                                 0::numeric as valor_saldo_cm
			FROM con.foto_cartera as foto
                        LEFT JOIN tem.facturas_indemnizar_fianza_micro tem_fac ON tem_fac.negocio = foto.negasoc AND tem_fac.cuota = foto.num_doc_fen
                        LEFT JOIN administrativo.control_indemnizacion_fianza AS  ctrl on (ctrl.documento=foto.documento AND ctrl.negocio =foto.negasoc )
			INNER JOIN con.cmc_doc AS cmc on (cmc.cmc=foto.cmc AND cmc.tipodoc=foto.tipo_documento)
			WHERE foto.negasoc= facturasVencidas.negocio
			AND foto.documento LIKE 'MC%'
                        AND foto.periodo_lote = periodo_corte
			AND valor_saldo > 0
			AND foto.reg_status !='A'
			AND tem_fac.negocio IS NULL
                        AND ctrl.documento IS NULL
			ORDER BY  foto.num_doc_fen::NUMERIC;

	       END LOOP;
	END IF;

	--arma la consulta para realizar los calculos de sanciones y de mas
       IF(acelerar_pagare)THEN
                SQLResult:='SELECT nombre_linea_negocio,
				   codcli,
				   nit_cliente,
				   nombre_cliente,
				   periodo_foto,
				   negocio,
				   num_pagare,
				   ''''::varchar AS documento,
				   ''''::varchar AS cuota,
				   ''0099-01-01''::date AS fecha_vencimiento,
				   0::int AS dias_mora,
				   sum(valor_factura)::numeric AS valor_factura,
				   sum(valor_saldo_capital)::numeric AS valor_saldo_capital,
				   sum(valor_desistir)::numeric AS valor_desistir,
				   ''0099-01-01''::date as fecha_indemnizacion,
				   sum(valor_saldo_mi)::numeric AS valor_saldo_mi,
				   sum(valor_saldo_ca)::numeric AS valor_saldo_ca,
                                   sum(ixm)::numeric AS ixm,
                                   sum(gac)::numeric AS gac,
                                   sum(total_saldo)::numeric AS total_saldo,
                                   0::int AS convenio,
                                   ''''::varchar AS cuenta,
                                   ref_4,
                                   cartera_en,
                                   ''''::varchar AS estado,
				   ''''::varchar as altura_mora,
				   coalesce(tem.esquema,''N'')::character varying as esquema_old
			FROM tem.facturas_indemnizar_fianza_micro f
			LEFT JOIN tem.negocios_facturacion_old tem on (tem.cod_neg=f.negocio)
			GROUP BY
				nombre_linea_negocio,
				codcli,
				nit_cliente,
				nombre_cliente,
				periodo_foto,
				negocio,
				num_pagare,
				ref_4,
				cartera_en,
				tem.esquema
			ORDER BY nit_cliente,negocio;';

			RAISE INFO 'dias_mora: %',SQLResult;
       ELSE
               SQLResult:='SELECT f.*, eg_altura_mora_periodo('''',''1'',3,dias_mora)::varchar as altura_mora , coalesce(tem.esquema,''N'')::character varying as esquema_old
			   FROM tem.facturas_indemnizar_fianza_micro f
			   LEFT JOIN tem.negocios_facturacion_old tem on (tem.cod_neg=f.negocio)
                           ORDER BY nit_cliente,negocio,cuota::int;';

       END IF;


        SQLResult:='SELECT f.*, eg_altura_mora_periodo('''',''1'',3,dias_mora)::varchar as altura_mora , coalesce(tem.esquema,''N'')::character varying as esquema_old
			   FROM tem.facturas_indemnizar_fianza_micro f
			   LEFT JOIN tem.negocios_facturacion_old tem on (tem.cod_neg=f.negocio)
                           ORDER BY nit_cliente,negocio,cuota::int;';

        raise notice 'SQLResult : %',SQLResult;
        FOR listaFacturas IN EXECUTE SQLResult	LOOP

                saldoMI=0;
		saldoCA=0;
		sumaConceptos=0;
                tasaIm=0;
		tasaIg=0;
                ixmItem=0;
                gacItem=0;
                sumaSaldo=0;
		resta=0;

		--FACTURAS VENCIDAS
		IF (listaFacturas.dias_mora > 0) THEN

			--VALIDAMOS EL ESQUEMA DEL NEGOCIO
			IF(listaFacturas.esquema_old='S')THEN

				/* ******************************************************
				* buscamos el saldo de  la cuota en iterada facturas MI *
				*********************************************************/
				SELECT INTO saldoMI coalesce(sum(valor_saldo),0)
				FROM con.foto_cartera foto
				WHERE  foto.negasoc= listaFacturas.negocio
				AND foto.num_doc_fen= listaFacturas.cuota
				AND foto.documento LIKE 'MI%'
				AND valor_saldo > 0
				AND foto.periodo_lote = listaFacturas.periodo_foto
				AND foto.reg_status !='A' ;

				IF (FOUND) THEN

				 listaFacturas.valor_saldo_mi=saldoMI;

				END IF;

			       /* ******************************************************
				* buscamos el saldo de la cuota en iterada facturas CA *
				*******************************************************/

				SELECT INTO saldoCA coalesce(sum(valor_saldo),0)
				FROM con.foto_cartera foto
				WHERE  foto.negasoc= listaFacturas.negocio
				AND foto.num_doc_fen= listaFacturas.cuota
				AND foto.documento LIKE 'CA%'
				AND valor_saldo > 0
				AND foto.periodo_lote = listaFacturas.periodo_foto
				AND foto.reg_status !='A' ;

				IF (FOUND) THEN

				listaFacturas.valor_saldo_ca=	saldoCA;
				RAISE NOTICE 'suma conceptaos %',saldoCA;

				END IF;


			ELSE

				--BUSCAMMOS LOS SALDO DE CADA CONCEPTO SEGUN EL CRITERIO DE APLICACION..
				SELECT INTO _detalleSaldoFacturas documento, negocio , cuota ,total_factura ,
								  saldo_capital,saldo_interes,saldo_cat,saldo_cuota_manejo,
								  saldo_seguro,total_abonos,saldo_factura
				FROM  eg_detalle_saldo_facturas_mc(listaFacturas.negocio::VARCHAR,listaFacturas.cuota::INTEGER);

				listaFacturas.valor_saldo_mi:=_detalleSaldoFacturas.saldo_interes;
				listaFacturas.valor_saldo_ca:=_detalleSaldoFacturas.saldo_cat;
				listaFacturas.valor_saldo_cm:=_detalleSaldoFacturas.saldo_cuota_manejo;


			END IF;

			RAISE NOTICE 'listaFacturas.valor_saldo_mi: % listaFacturas.valor_saldo_ca: %',listaFacturas.valor_saldo_mi,listaFacturas.valor_saldo_ca;

			/********************************************************
			* Calcular sanciones :  Suma CAPs + MIs + CAs , IxM, GaC *
			**********************************************************/
			sumaConceptos=listaFacturas.valor_saldo_capital+listaFacturas.valor_saldo_cm+saldoMI + saldoCA ;

			--validamos si se debe cobrar gastos de cobranza.
			IF(_gac)THEN

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

				END IF;

			END IF;


			/* *****************
			 ** Suma saldos *****
			*********************/
			sumaSaldo = sumaConceptos + listaFacturas.IxM +listaFacturas.GaC;
			listaFacturas.total_saldo = sumaSaldo;
			fechaAnterior =listaFacturas.fecha_vencimiento;

		ELSE --cuotas futuras

			--valor interes cuota
			SELECT INTO filaLiquidador * FROM documentos_neg_aceptado d   where d.cod_neg=listaFacturas.negocio and d.item =listaFacturas.cuota and reg_status='';


			/* ***********************************************
			* Verificamos si es la primera cuaota corriente *
			* Despues de la vencidas                        *
			*************************************************/

			resta= listaFacturas.fecha_vencimiento - fechaAnterior;

			IF(resta between 27  and 34)THEN --esta condicion solo me sirve para saber cual es al cuota
			    raise notice 'my hoy - fecha vencimiento anterior %',(now()::date-fechaAnterior::date);

			    diasInteresCorriente:=now()::date-fechaAnterior::date;
			    IF(diasInteresCorriente > 30) THEN diasInteresCorriente:=30; END IF;

			     nuevoInteres:=ROUND((filaLiquidador.interes/30)*(diasInteresCorriente));
                             --saldoMI :=nuevoInteres;
			END IF;
			listaFacturas.valor_saldo_capital:=listaFacturas.valor_saldo_capital-filaLiquidador.seguro;
			listaFacturas.valor_saldo_ca=filaLiquidador.cat;
			listaFacturas.total_saldo= listaFacturas.valor_saldo_capital + saldoMI + filaLiquidador.cat;
			--listaFacturas.total_saldo= listaFacturas.valor_saldo_capital + saldoMI ;
		END IF;





                RETURN NEXT listaFacturas;


        END LOOP;

END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_det_facturas_indemnizar_fianza_micro(character varying, character varying, integer, character varying, integer, character varying, boolean, boolean)
  OWNER TO postgres;
