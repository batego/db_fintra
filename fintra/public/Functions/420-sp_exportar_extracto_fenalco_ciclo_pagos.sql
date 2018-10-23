-- Function: sp_exportar_extracto_fenalco_ciclo_pagos(numeric, numeric, numeric)

-- DROP FUNCTION sp_exportar_extracto_fenalco_ciclo_pagos(numeric, numeric, numeric);

CREATE OR REPLACE FUNCTION sp_exportar_extracto_fenalco_ciclo_pagos(unidadnegocio numeric, periodoasignacion numeric, nciclo numeric)
  RETURNS SETOF record AS
$BODY$

DECLARE

	CarteraExtracto record;
	ExtractoCategoria record;
	SolicitudPersona record;

	sinCity record;
	sinEstado record;

	dcapital_cte numeric;
	dcapital_vencido numeric;
	dinteres_fin_cte numeric;
	dinteres_fin_vencido numeric;
	dcat numeric;
	dinteres_xmora numeric;
	dgastos_cobranza numeric;
	ddscto_interes_cte numeric;
	ddscto_interes_xmora numeric;
	ddscto_gastos_cobranza numeric;
	ddscto_capital numeric;
	ddscto_seguro numeric;

	_TotalCuotas numeric;
	_TotalCuotasVencidas numeric;
	_TotalCuotasFaltantes numeric;
	_CtasPentesFaltantes numeric;
	_TotalCuotasPendientes numeric;

	vencimiento_mayor varchar;
	und_neg varchar;
	estab_comercio varchar;
	_agencia varchar;
	Ciclo record;

BEGIN

       SELECT INTO Ciclo * FROM con.ciclos_facturacion WHERE periodo = periodoasignacion AND num_ciclo = nciclo;

	FOR CarteraExtracto IN

		SELECT
			rop.id::numeric,
			rop.cod_rop::varchar,
			''::varchar as cod_rop_barcode,
			Ciclo.fecha_preparacion::varchar as generado_el,
			rop.vencimiento_rop::varchar,
			''::varchar as venc_mayor,
			rop.negocio::varchar,
			rop.cedula::varchar,
			rop.nombre_cliente::varchar,
			rop.direccion::varchar,
			''::varchar as departamento,
			''::varchar as ciudad,
			''::varchar as barrio,
			''::varchar as agencia,
			''::varchar as linea_producto,
			rop.cuotas_vencidas::varchar,
			rop.cuotas_pendientes::varchar,
			rop.dias_vencidos::varchar,
			fecha_ultimo_pago::varchar as fch_ultimo_pago,
			rop.subtotal::numeric as subtotal_rop,
			rop.total_sanciones::numeric,
			rop.total_descuentos::numeric,
			rop.total::numeric as total_rop,
			rop.total_abonos::numeric,
			rop.observacion::varchar,
			rop.msg_paguese_antes::varchar,
			rop.msg_estado_credito::varchar,
			0::numeric as capital,
			0::numeric as interes_financiacion,
			0::numeric as cat,
			0::numeric as interes_xmora,
			0::numeric as gastos_cobranza,
			0::numeric as dscto_capital,
			0::numeric as dscto_seguro,
			0::numeric as dscto_interes_financiacion,
			0::numeric as dscto_interes_xmora,
			0::numeric as dscto_gastos_cobranza,
			0::numeric as subtotal_corriente,
			0::numeric as subtotal_vencido,
			0::numeric as ksubtotalneto,
			0::numeric as kdescuentos,
			0::numeric as ktotal,
			''::varchar as est_comercio,
			''::varchar as telefono
		FROM recibo_oficial_pago rop where duplicado = 'N' and id_unidad_negocio = unidadnegocio and id_ciclo = Ciclo.id /*and negocio = ''*/ LOOP
			raise notice 'CarteraExtracto.negocio : %',CarteraExtracto.negocio;
			dcapital_cte = 0;
			dcapital_vencido = 0;
			dinteres_fin_cte = 0;
			dinteres_fin_vencido = 0;
			dcat = 0;
			dinteres_xmora = 0;
			dgastos_cobranza = 0;

			ddscto_capital = 0;
			ddscto_seguro = 0;
			ddscto_interes_cte = 0;
			ddscto_interes_xmora = 0;
			ddscto_gastos_cobranza = 0;

			SELECT INTO und_neg descripcion from unidad_negocio where id = unidadnegocio;
			SELECT INTO estab_comercio payment_name from proveedor pv where nit = (select nit_tercero from negocios where cod_neg = CarteraExtracto.negocio);
			SELECT INTO _agencia SUBSTRING(CarteraExtracto.negocio,1,2);

			IF(_agencia = 'FB') THEN
				CarteraExtracto.agencia = 'BOLIVAR';
			ELSE
				CarteraExtracto.agencia = 'ATLANTICO';
			END IF;

			CarteraExtracto.linea_producto = und_neg;
			CarteraExtracto.est_comercio = estab_comercio;

			FOR ExtractoCategoria IN

				select
				  (select categoria from conceptos_recaudo where id = dr.id_conceptos_recaudo) as categoria
				  ,sum(dr.valor_concepto) as valor_concepto
				  ,descripcion
				from detalle_rop dr
				where dr.id_rop = CarteraExtracto.id
				group by categoria,descripcion LOOP

				if ( ExtractoCategoria.categoria in ('CAP','AVA') ) then

					--select * from conceptos_recaudo
					--.::#::.
					if ( ExtractoCategoria.descripcion in ('CAPITAL CORRIENTE','AVAL CORRIENTE') ) then

						--CarteraExtracto.capital_cte = round(ExtractoCategoria.valor_concepto);
						dcapital_cte = dcapital_cte + round(ExtractoCategoria.valor_concepto);

					elsif ( ExtractoCategoria.descripcion in ('CAPITAL VENCIDO','AVAL VENCIDO') ) then

						--CarteraExtracto.capital_vcdo = round(ExtractoCategoria.valor_concepto);
						dcapital_vencido = dcapital_vencido + round(ExtractoCategoria.valor_concepto);
					end if;

				elsif ( ExtractoCategoria.categoria = 'INT' ) then
					--.::#::.
					if ( ExtractoCategoria.descripcion in ('INTERES CORRIENTE') ) then

						--CarteraExtracto.interes_cte = round(ExtractoCategoria.valor_concepto);
						dinteres_fin_cte = dinteres_fin_cte + round(ExtractoCategoria.valor_concepto);

					elsif ( ExtractoCategoria.descripcion in ('INTERES VENCIDO') ) then

						--CarteraExtracto.interes_vcdo = round(ExtractoCategoria.valor_concepto);
						dinteres_fin_vencido = dinteres_fin_vencido + round(ExtractoCategoria.valor_concepto);
					end if;

				elsif ( ExtractoCategoria.categoria = 'IXM' ) then
					--.::#::.
					CarteraExtracto.interes_xmora = round(ExtractoCategoria.valor_concepto);
					dinteres_xmora = dinteres_xmora + round(ExtractoCategoria.valor_concepto);

				elsif ( ExtractoCategoria.categoria = 'GAC' ) then
					--.::#::.
					CarteraExtracto.gastos_cobranza = round(ExtractoCategoria.valor_concepto);
					dgastos_cobranza = dgastos_cobranza + round(ExtractoCategoria.valor_concepto);

				elsif ( ExtractoCategoria.categoria = 'DCAP' ) then
					--.::#::.
					CarteraExtracto.dscto_capital = round(ExtractoCategoria.valor_concepto);
					ddscto_capital = round(ExtractoCategoria.valor_concepto);

				elsif ( ExtractoCategoria.categoria = 'DSEG' ) then
					--.::#::.
					CarteraExtracto.dscto_seguro= round(ExtractoCategoria.valor_concepto);
					ddscto_seguro = round(ExtractoCategoria.valor_concepto);

				elsif ( ExtractoCategoria.categoria = 'DIXM' ) then
					--.::#::.
					CarteraExtracto.dscto_interes_xmora = round(ExtractoCategoria.valor_concepto);
					ddscto_interes_xmora = ddscto_interes_xmora + round(ExtractoCategoria.valor_concepto);

				elsif ( ExtractoCategoria.categoria = 'DGAC' ) then
					--.::#::.
					CarteraExtracto.dscto_gastos_cobranza = round(ExtractoCategoria.valor_concepto);
					ddscto_gastos_cobranza = ddscto_gastos_cobranza + round(ExtractoCategoria.valor_concepto);

				elsif ( ExtractoCategoria.categoria = 'DINT' ) then
					--.::#::.
					CarteraExtracto.dscto_interes_financiacion = round(ExtractoCategoria.valor_concepto);
					ddscto_interes_cte = ddscto_interes_cte + round(ExtractoCategoria.valor_concepto);

				end if;

			END LOOP;

				CarteraExtracto.capital = dcapital_cte + dcapital_vencido;
				CarteraExtracto.interes_financiacion = dinteres_fin_cte + dinteres_fin_vencido;

				CarteraExtracto.subtotal_corriente = dcapital_cte + dinteres_fin_cte;
				CarteraExtracto.subtotal_vencido = dcapital_vencido + dinteres_fin_vencido;

				CarteraExtracto.ksubtotalneto = dcapital_cte + dcapital_vencido + dinteres_fin_cte + dinteres_fin_vencido + dcat + dinteres_xmora + dgastos_cobranza;
				CarteraExtracto.kdescuentos = ddscto_capital + ddscto_seguro + ddscto_interes_cte + ddscto_interes_xmora + ddscto_gastos_cobranza;
				CarteraExtracto.ktotal = CarteraExtracto.ksubtotalneto - (ddscto_capital + ddscto_seguro + ddscto_interes_cte + ddscto_interes_xmora + ddscto_gastos_cobranza);

				select into SolicitudPersona * from nit where cedula = CarteraExtracto.cedula;
				--select into SolicitudPersona * from cliente where nit = CarteraExtracto.cedula;
				select into sinCity nomciu from ciudad where codciu = SolicitudPersona.codciu;
				select into sinEstado department_name from estado where department_code = SolicitudPersona.coddpto;

				CarteraExtracto.departamento = sinEstado;
				CarteraExtracto.ciudad = sinCity;
				CarteraExtracto.barrio = SolicitudPersona.barrio;
				CarteraExtracto.cod_rop_barcode = '000'||substring(CarteraExtracto.cod_rop,4);
				CarteraExtracto.telefono = SolicitudPersona.telefono||'-'||SolicitudPersona.celular;

				/*
				SELECT INTO _TotalCuotas count(0) from documentos_neg_aceptado where cod_neg = CarteraExtracto.negocio;
				SELECT INTO _TotalCuotasVencidas count(0) as CtasVencidas from con.foto_ciclo_pagos  where reg_status = '' and dstrct = 'FINV' and tipo_documento in ('FAC','NDC') and negasoc = CarteraExtracto.negocio and id_convenio = (select id_convenio from negocios where cod_neg = CarteraExtracto.negocio) and valor_saldo > 0 and periodo_lote = periodoasignacion and num_ciclo=ciclo and replace(substring(fecha_vencimiento,1,7),'-','')::numeric <= periodoasignacion and substring(documento,1,2) not in ('CP','FF','DF') and descripcion not in ('CXC AVAL','CXC_INTERES_FA','CXC_CAT_MC','CXC_INTERES_MC');
			        SELECT INTO _TotalCuotasFaltantes count(0) as CtasFaltantes from con.foto_ciclo_pagos where reg_status = '' and dstrct = 'FINV' and tipo_documento in ('FAC','NDC') and negasoc = CarteraExtracto.negocio and id_convenio = (select id_convenio from negocios where cod_neg = CarteraExtracto.negocio) and valor_saldo > 0 and periodo_lote = periodoasignacion and num_ciclo=ciclo and substring(documento,1,2) not in ('CP','FF','DF') and descripcion not in ('CXC AVAL','CXC_INTERES_FA','CXC_CAT_MC','CXC_INTERES_MC');

				CarteraExtracto.cuotas_vencidas = _TotalCuotasVencidas;
				CarteraExtracto.cuotas_pendientes = _TotalCuotasFaltantes||' de '||_TotalCuotas;
				*/

				if ( CarteraExtracto.msg_estado_credito = 'AL DIA' ) then
					CarteraExtracto.msg_paguese_antes = (select max(fecha_vencimiento) from con.foto_ciclo_pagos where negasoc = CarteraExtracto.negocio and valor_saldo > 0 and fecha_vencimiento <= Ciclo.fecha_fin /*periodo_lote = periodo_corriente and num_ciclo = ciclo and replace(substring(fecha_vencimiento,1,7),'-','')::numeric = periodo_corriente*/);
					/*if ( CarteraExtracto.msg_paguese_antes is null ) then
						CarteraExtracto.msg_paguese_antes = (select max(fecha_vencimiento) from con.foto_ciclo_pagos where negasoc = CarteraExtracto.negocio and valor_saldo > 0 and periodo_lote = periodoasignacion and num_ciclo=ciclo and replace(substring(fecha_vencimiento,1,7),'-','')::numeric = periodoasignacion+1);
					end if;
					*/
				end if;

				SELECT INTO vencimiento_mayor 	CASE WHEN maxdia >= 365 THEN '8- MAYOR A 1 ANIO'
							     WHEN maxdia >= 181 THEN '7- ENTRE 180 Y 360'
							     WHEN maxdia >= 121 THEN '6- ENTRE 121 Y 180'
							     WHEN maxdia >= 91 THEN '5- ENTRE 91 Y 120'
							     WHEN maxdia >= 61 THEN '4- ENTRE 61 Y 90'
							     WHEN maxdia >= 31 THEN '3- ENTRE 31 Y 60'
							     WHEN maxdia >= 1 THEN '2- 1 A 30'
							     WHEN maxdia <= 0 THEN '1- CORRIENTE'
								ELSE '0' END AS rango
							FROM (
							 SELECT max(Ciclo.fecha_preparacion::date-(fecha_vencimiento)) as maxdia
							 FROM con.foto_ciclo_pagos fra
							 WHERE fra.dstrct = 'FINV'
								  AND fra.valor_saldo > 0
								  AND fra.reg_status = ''
								  AND fra.negasoc = CarteraExtracto.negocio
								  AND fra.tipo_documento in ('FAC','NDC')
								  AND substring(fra.documento,1,2) not in ('CP','FF','DF')
								  AND fra.fecha_vencimiento <= Ciclo.fecha_fin
								  AND fra.periodo_lote = periodoasignacion
								  --and fra.num_ciclo=ciclo
							 GROUP BY negasoc

							) vencimiento;

				CarteraExtracto.venc_mayor = vencimiento_mayor;

		RETURN NEXT CarteraExtracto;

	END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_exportar_extracto_fenalco_ciclo_pagos(numeric, numeric, numeric)
  OWNER TO postgres;
