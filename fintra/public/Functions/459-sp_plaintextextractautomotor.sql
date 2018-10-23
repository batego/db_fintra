-- Function: sp_plaintextextractautomotor(numeric, numeric, date)

-- DROP FUNCTION sp_plaintextextractautomotor(numeric, numeric, date);

CREATE OR REPLACE FUNCTION sp_plaintextextractautomotor(unidadnegocio numeric, periodoasignacion numeric, fue_generado date)
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
	ddscto_capital numeric;
	dgastos_cobranza numeric;
	ddscto_interes_cte numeric;
	ddscto_interes_xmora numeric;
	ddscto_gastos_cobranza numeric;

	_TotalCuotas numeric;
	_TotalCuotasVencidas numeric;
	_TotalCuotasFaltantes numeric;
	_CtasPentesFaltantes numeric;
	_TotalCuotasPendientes numeric;

BEGIN

	FOR CarteraExtracto IN

		SELECT
			rop.id::numeric,
			rop.cod_rop::varchar,
			''::varchar as cod_rop_barcode,
			fue_generado::varchar as generado_el, --'2014-06-01'::varchar as generado_el,
			rop.vencimiento_rop::varchar,
			rop.negocio::varchar,
			rop.cedula::varchar,
			rop.nombre_cliente::varchar,
			rop.direccion::varchar,
			''::varchar as departamento, --DEPARTAMENTO
			''::varchar as ciudad, --CIUDAD
			''::varchar as barrio, --BARRIO
			'AUTOMOTOR'::varchar as linea_producto,
			''::varchar as cuotas_vencidas, --''::varchar as cuotas_vencidas, --rop.cuotas_vencidas::varchar,
			''::varchar as cuotas_pendientes, --rop.cuotas_pendientes::varchar,
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
			0::numeric as seguros,
			0::numeric as interes_xmora,
			0::numeric as gastos_cobranza,
			0::numeric as dscto_capital,
			0::numeric as dscto_interes_cte,
			0::numeric as dscto_interes_xmora,
			0::numeric as dscto_gastos_cobranza,
			0::numeric as ksubtotal_corriente,
			0::numeric as ksubtotal_vencido,
			0::numeric as ksubtotalneto,
			0::numeric as kdescuentos,
			0::numeric as ktotal
			--select *
		FROM recibo_oficial_pago rop where id_unidad_negocio = unidadnegocio and periodo_rop = periodoasignacion::varchar LOOP --FA12031 | FA06518 -- and negocio = 'FA09549'

			dcapital_cte = 0;
			dcapital_vencido = 0;
			dinteres_fin_cte = 0;
			dinteres_fin_vencido = 0;
			dcat = 0;
			dinteres_xmora = 0;
			dgastos_cobranza = 0;
			ddscto_capital = 0;
			ddscto_interes_cte = 0;
			ddscto_interes_xmora = 0;
			ddscto_gastos_cobranza = 0;


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
					CarteraExtracto.dscto_interes_cte = round(ExtractoCategoria.valor_concepto);
					ddscto_interes_cte = ddscto_interes_cte + round(ExtractoCategoria.valor_concepto);

				elsif ( ExtractoCategoria.categoria = 'DCAP' ) then
					--.::#::.
					CarteraExtracto.dscto_capital = round(ExtractoCategoria.valor_concepto);
					ddscto_capital = round(ExtractoCategoria.valor_concepto);
				end if;

			END LOOP;

				CarteraExtracto.capital = dcapital_cte + dcapital_vencido;
				CarteraExtracto.interes_financiacion = dinteres_fin_cte + dinteres_fin_vencido;

				CarteraExtracto.ksubtotal_corriente = dcapital_cte + dinteres_fin_cte;
				CarteraExtracto.ksubtotal_vencido = dcapital_vencido + dinteres_fin_vencido;

				CarteraExtracto.ksubtotalneto = dcapital_cte + dcapital_vencido + dinteres_fin_cte + dinteres_fin_vencido + dcat + dinteres_xmora + dgastos_cobranza;
				CarteraExtracto.kdescuentos = ddscto_capital + ddscto_interes_cte + ddscto_interes_xmora + ddscto_gastos_cobranza;
				CarteraExtracto.ktotal = CarteraExtracto.ksubtotalneto - (ddscto_capital + ddscto_interes_cte + ddscto_interes_xmora + ddscto_gastos_cobranza);

				--select into SolicitudPersona * from solicitud_persona where numero_solicitud = (select numero_solicitud from solicitud_aval where cod_neg = CarteraExtracto.negocio);
				--select into SolicitudPersona * from solicitud_persona where numero_solicitud = (select numero_solicitud from solicitud_aval where cod_neg = (select max(cod_neg) from negocios where cod_cli = CarteraExtracto.cedula and substring(cod_neg,1,2) != 'NG'));

				select into SolicitudPersona * from nit where cedula = CarteraExtracto.cedula; --
				select into sinCity nomciu from ciudad where codciu = SolicitudPersona.codciu;
				--select into sinEstado department_name from estado where department_code = SolicitudPersona.departamento;
				select into sinEstado department_name from estado where department_code = SolicitudPersona.coddpto; --

				CarteraExtracto.departamento = sinEstado;
				CarteraExtracto.ciudad = sinCity;
				CarteraExtracto.barrio = SolicitudPersona.barrio;
				CarteraExtracto.cod_rop_barcode = '000'||substring(CarteraExtracto.cod_rop,4);


				SELECT INTO _TotalCuotas count(0) from documentos_neg_aceptado where cod_neg = CarteraExtracto.negocio;

				--SELECT INTO _TotalCuotasVencidas count(0) as CtasVencidas from con.foto_cartera where reg_status = '' and dstrct = 'FINV' and tipo_documento = 'FAC' and negasoc = CarteraExtracto.negocio and id_convenio = (select id_convenio from negocios where cod_neg = CarteraExtracto.negocio) and valor_saldo > 0 and periodo_lote = 201406 and replace(substring(fecha_vencimiento,1,7),'-','')::numeric < 201406 and substring(documento,1,2) != 'CP';
				--SELECT INTO _TotalCuotasPendientes count(0) as CtasPendientes from con.foto_cartera where reg_status = '' and dstrct = 'FINV' and tipo_documento = 'FAC' and negasoc = CarteraExtracto.negocio and id_convenio = (select id_convenio from negocios where cod_neg = CarteraExtracto.negocio) and valor_saldo > 0 and periodo_lote = 201406 and replace(substring(fecha_vencimiento,1,7),'-','')::numeric <= 201406 and substring(documento,1,2) != 'CP';
				--SELECT INTO _TotalCuotasFaltantes count(0) as CtasFaltantes from con.foto_cartera where reg_status = '' and dstrct = 'FINV' and tipo_documento = 'FAC' and negasoc = CarteraExtracto.negocio and id_convenio = (select id_convenio from negocios where cod_neg = CarteraExtracto.negocio) and valor_saldo > 0 and periodo_lote = 201406 and replace(substring(fecha_vencimiento,1,7),'-','')::numeric > 201406 and substring(documento,1,2) != 'CP' ;

				SELECT INTO _TotalCuotasVencidas count(0) as CtasVencidas from con.foto_cartera where reg_status = '' and dstrct = 'FINV' and tipo_documento in ('FAC','NDC') and negasoc = CarteraExtracto.negocio and id_convenio = (select id_convenio from negocios where cod_neg = CarteraExtracto.negocio) and valor_saldo > 0 and periodo_lote = periodoasignacion /*and fecha_vencimiento <= fue_generado*/ and replace(substring(fecha_vencimiento,1,7),'-','')::numeric <= periodoasignacion and substring(documento,1,2) not in ('CP','FF','DF') and descripcion not in ('CXC AVAL','CXC_INTERES_FA','CXC_CAT_MC','CXC_INTERES_MC');
			        SELECT INTO _TotalCuotasFaltantes count(0) as CtasFaltantes from con.foto_cartera where reg_status = '' and dstrct = 'FINV' and tipo_documento in ('FAC','NDC') and negasoc = CarteraExtracto.negocio and id_convenio = (select id_convenio from negocios where cod_neg = CarteraExtracto.negocio) and valor_saldo > 0 and periodo_lote = periodoasignacion and substring(documento,1,2) not in ('CP','FF','DF') and descripcion not in ('CXC AVAL','CXC_INTERES_FA','CXC_CAT_MC','CXC_INTERES_MC');

				CarteraExtracto.cuotas_vencidas = _TotalCuotasVencidas;-- + _TotalCuotasFaltantes;
				CarteraExtracto.cuotas_pendientes = _TotalCuotasFaltantes||' de '||_TotalCuotas;


				if ( CarteraExtracto.msg_estado_credito = 'AL DIA' ) then

					--CarteraExtracto.msg_paguese_antes = (select max(fecha_vencimiento) from con.foto_cartera where negasoc = CarteraExtracto.negocio and valor_saldo > 0 and periodo_lote = 201406 and replace(substring(fecha_vencimiento,1,7),'-','')::numeric = 201406);
					CarteraExtracto.msg_paguese_antes = (select max(fecha_vencimiento) from con.foto_cartera where negasoc = CarteraExtracto.negocio and valor_saldo > 0 and periodo_lote = periodoasignacion and replace(substring(fecha_vencimiento,1,7),'-','')::numeric = periodoasignacion);
					if ( CarteraExtracto.msg_paguese_antes is null ) then
						CarteraExtracto.msg_paguese_antes = (select max(fecha_vencimiento) from con.foto_cartera where negasoc = CarteraExtracto.negocio and valor_saldo > 0 and periodo_lote = periodoasignacion and replace(substring(fecha_vencimiento,1,7),'-','')::numeric = periodoasignacion+1);
					end if;

				end if;

		RETURN NEXT CarteraExtracto;

	END LOOP;


		/*
		select
			rop.cod_rop, rop.vencimiento_rop, rop.negocio, rop.cedula, rop.nombre_cliente, rop.direccion, rop.ciudad, rop.cuotas_vencidas, rop.cuotas_pendientes, rop.dias_vencidos,
			rop.subtotal, rop.total_sanciones, rop.total_descuentos, rop.total, rop.total_abonos, rop.observacion, rop.msg_paguese_antes, rop.msg_estado_credito
			,(select categoria from conceptos_recaudo where id = dr.id_conceptos_recaudo) as categoria
			,sum(dr.valor_concepto) as valor_concepto, sum(dr.valor_descuento) as valor_descuento, sum(dr.valor_ixm) as valor_ixm, sum(dr.valor_descuento_ixm) as valor_descuento_ixm,
			sum(dr.valor_gac) as valor_gac, sum(dr.valor_descuento_gac) as valor_descuento_gac

		from recibo_oficial_pago rop, detalle_rop dr
		where rop.id = dr.id_rop and id_unidad_negocio = 3 and periodo_rop = '201406'
		group by
		rop.cod_rop, rop.vencimiento_rop, rop.cedula, rop.negocio, rop.nombre_cliente, rop.direccion, rop.ciudad, rop.cuotas_vencidas, rop.cuotas_pendientes, rop.dias_vencidos,
		rop.subtotal, rop.total_sanciones, rop.total_descuentos, rop.total, rop.total_abonos, rop.observacion, rop.msg_paguese_antes, rop.msg_estado_credito
		,categoria
		*/

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_plaintextextractautomotor(numeric, numeric, date)
  OWNER TO postgres;
