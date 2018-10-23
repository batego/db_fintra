-- Function: sp_exportar_extracto_micro_ciclo_pagos(numeric, numeric, numeric)

-- DROP FUNCTION sp_exportar_extracto_micro_ciclo_pagos(numeric, numeric, numeric);

CREATE OR REPLACE FUNCTION sp_exportar_extracto_micro_ciclo_pagos(unidadnegocio numeric, periodoasignacion numeric, nciclo numeric)
  RETURNS SETOF record AS
$BODY$

DECLARE

	CarteraExtracto record;
	ExtractoCategoria record;
	SolicitudPersona record;
	ClienteRec record;
	sinCity record;
	sinEstado record;

	dcapital numeric;
	dinteres_cte numeric;
	dcat numeric;
	dinteres_xmora numeric;
	dgastos_cobranza numeric;
	ddscto_interes_cte numeric;
	ddscto_interes_xmora numeric;
	ddscto_gastos_cobranza numeric;
	ddscto_capital numeric;
	ddscto_cat numeric;
	dcapital_cte numeric;
	dcapital_vencido numeric;
	dinteres_fin_cte numeric;
	dinteres_fin_vencido numeric;

	_TotalCuotas numeric;
	_TotalCuotasVencidas numeric;
	_TotalCuotasFaltantes numeric;
	_CtasPentesFaltantes numeric;
	_TotalCuotasPendientes numeric;

	vencimiento_mayor varchar;
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
			rop.vencimiento_mayor::varchar as venc_mayor,
			rop.negocio::varchar,
			rop.cedula::varchar,
			rop.nombre_cliente::varchar,
			rop.direccion::varchar,
			''::varchar as departamento,
			''::varchar as ciudad,
			''::varchar as barrio,
			''::varchar as agencia,
			'MICROCREDITO'::varchar as linea_producto,
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
			0::numeric as interes_cte,
			0::numeric as cat,
			0::numeric as interes_xmora,
			0::numeric as gastos_cobranza,
			0::numeric as dscto_capital,
			0::numeric as dscto_cat,
			0::numeric as dscto_interes_financiacion,
			0::numeric as dscto_interes_xmora,
			0::numeric as dscto_gastos_cobranza,
			0::numeric as subtotal_corriente,
			0::numeric as subtotal_vencido,
			0::numeric as ksubtotal,
			0::numeric as kdescuentos,
			0::numeric as ktotal,
			''::varchar as telefono
		FROM recibo_oficial_pago rop where duplicado = 'N' and id_unidad_negocio = unidadnegocio and id_ciclo = Ciclo.id  LOOP

			dcapital = 0;
			dcapital_cte = 0;
			dcapital_vencido = 0;
			dinteres_cte = 0;
			dinteres_fin_cte = 0;
			dinteres_fin_vencido = 0;
			dcat = 0;
			dinteres_xmora = 0;
			dgastos_cobranza = 0;
			ddscto_interes_cte = 0;
			ddscto_interes_xmora = 0;
			ddscto_gastos_cobranza = 0;
			ddscto_capital = 0;
			ddscto_cat = 0;

			RAISE NOTICE 'NEGOCIO: %',CarteraExtracto.negocio;

			FOR ExtractoCategoria IN

						SELECT (SELECT categoria FROM conceptos_recaudo WHERE id = dr.id_conceptos_recaudo) as categoria,
							sum(dr.valor_concepto) as valor_concepto,
							descripcion
							FROM detalle_rop dr
							WHERE dr.id_rop = CarteraExtracto.id and dr.negocio=CarteraExtracto.negocio GROUP BY categoria,descripcion
			LOOP

				if ( ExtractoCategoria.categoria = 'CAP' ) then
					--.::#::.
					dcapital = dcapital + ExtractoCategoria.valor_concepto;

					if ( ExtractoCategoria.descripcion in ('CAPITAL CORRIENTE') ) then

						dcapital_cte = dcapital_cte + round(ExtractoCategoria.valor_concepto);
						raise notice 'CAP CTE: %',dcapital_cte;

					elsif ( ExtractoCategoria.descripcion in ('CAPITAL VENCIDO') ) then

						dcapital_vencido = dcapital_vencido + round(ExtractoCategoria.valor_concepto);
						raise notice 'CAP VEN: %',dcapital_vencido;
					end if;

				elsif ( ExtractoCategoria.categoria = 'INT' ) then

					--.::#::.
					dinteres_cte = dinteres_cte + ExtractoCategoria.valor_concepto;

					if ( ExtractoCategoria.descripcion in ('INTERES CORRIENTE') ) then

						dinteres_fin_cte = dinteres_fin_cte + round(ExtractoCategoria.valor_concepto);
						raise notice 'INT CTE: %',dinteres_fin_cte;

					elsif ( ExtractoCategoria.descripcion in ('INTERES VENCIDO') ) then

						dinteres_fin_vencido = dinteres_fin_vencido + round(ExtractoCategoria.valor_concepto);
						raise notice 'INT VEN: %',dinteres_fin_vencido;
					end if;

				elsif ( ExtractoCategoria.categoria = 'CAT' ) then

					--.::#::.
					dcat = dcat + ExtractoCategoria.valor_concepto;
					raise notice 'dcat: %',ExtractoCategoria.valor_concepto;

				elsif ( ExtractoCategoria.categoria = 'IXM' ) then

					--.::#::.
					CarteraExtracto.interes_xmora = round(ExtractoCategoria.valor_concepto);
					dinteres_xmora = round(ExtractoCategoria.valor_concepto);

				elsif ( ExtractoCategoria.categoria = 'GAC' ) then

					--.::#::.
					CarteraExtracto.gastos_cobranza = round(ExtractoCategoria.valor_concepto);
					dgastos_cobranza = round(ExtractoCategoria.valor_concepto);

				elsif ( ExtractoCategoria.categoria = 'DCAP' ) then

					--.::#::.
					CarteraExtracto.dscto_capital = round(ExtractoCategoria.valor_concepto);
					ddscto_capital = round(ExtractoCategoria.valor_concepto);

				elsif ( ExtractoCategoria.categoria = 'DCAT' ) then

					--.::#::.
					CarteraExtracto.dscto_cat = round(ExtractoCategoria.valor_concepto);
					ddscto_cat = round(ExtractoCategoria.valor_concepto);

				elsif ( ExtractoCategoria.categoria = 'DIXM' ) then

					--.::#::.
					CarteraExtracto.dscto_interes_xmora = round(ExtractoCategoria.valor_concepto);
					ddscto_interes_xmora = round(ExtractoCategoria.valor_concepto);

				elsif ( ExtractoCategoria.categoria = 'DGAC' ) then

					--.::#::.
					CarteraExtracto.dscto_gastos_cobranza = round(ExtractoCategoria.valor_concepto);
					ddscto_gastos_cobranza = round(ExtractoCategoria.valor_concepto);

				elsif ( ExtractoCategoria.categoria = 'DINT' ) then

					--.::#::.
					CarteraExtracto.dscto_interes_financiacion = round(ExtractoCategoria.valor_concepto);
					ddscto_interes_cte = round(ExtractoCategoria.valor_concepto);

				end if;

				raise notice 'LOOP INTERNO';

			END LOOP;

				raise notice 'capital: %',dcapital;
				CarteraExtracto.capital = round(dcapital);
				CarteraExtracto.interes_cte = round(dinteres_cte);
				CarteraExtracto.cat = round(dcat);

				CarteraExtracto.subtotal_corriente = dcapital_cte + dinteres_fin_cte;
				CarteraExtracto.subtotal_vencido = dcapital_vencido + dinteres_fin_vencido;
				CarteraExtracto.ksubtotal = dcapital + dinteres_cte + dcat + dinteres_xmora + dgastos_cobranza;
				CarteraExtracto.kdescuentos = ddscto_capital + ddscto_cat + ddscto_interes_cte + ddscto_interes_xmora + ddscto_gastos_cobranza;
				CarteraExtracto.ktotal = CarteraExtracto.ksubtotal - (ddscto_capital + ddscto_cat + ddscto_interes_cte + ddscto_interes_xmora + ddscto_gastos_cobranza);

				-- select into SolicitudPersona * from nit where cedula = CarteraExtracto.cedula;
-- 				select into sinCity nomciu from ciudad where codciu = SolicitudPersona.codciu;
-- 				select into sinEstado department_name from estado where department_code = SolicitudPersona.coddpto;

				SELECT INTO ClienteRec n.*,c.nomciu,e.department_name FROM nit n
				INNER JOIN ciudad c on (c.codciu=n.codciu)
				INNER JOIN estado e on (e.department_code=n.coddpto)
				WHERE n.cedula = CarteraExtracto.cedula;

				CarteraExtracto.direccion = ClienteRec.direccion;
				CarteraExtracto.departamento = ClienteRec.department_name;
				CarteraExtracto.ciudad = ClienteRec.nomciu;
				CarteraExtracto.barrio = ClienteRec.barrio;
				CarteraExtracto.agencia = 'BARRANQUILLA';
				CarteraExtracto.cod_rop_barcode = '000'||substring(CarteraExtracto.cod_rop,4);
				CarteraExtracto.telefono = ClienteRec.telefono||'-'||ClienteRec.celular;

-- 				IF ( CarteraExtracto.msg_estado_credito = 'AL DIA' ) THEN
--
-- 					CarteraExtracto.msg_paguese_antes = (SELECT max(fecha_vencimiento)
-- 										FROM con.foto_ciclo_pagos
-- 									     WHERE negasoc = CarteraExtracto.negocio AND valor_saldo > 0 AND fecha_vencimiento <= Ciclo.fecha_fin );
--
-- 				END IF;

	-- 			SELECT INTO vencimiento_mayor 	CASE WHEN maxdia >= 365 THEN '8- MAYOR A 1 ANIO'
-- 							     WHEN maxdia >= 181 THEN '7- ENTRE 180 Y 360'
-- 							     WHEN maxdia >= 121 THEN '6- ENTRE 121 Y 180'
-- 							     WHEN maxdia >= 91 THEN '5- ENTRE 91 Y 120'
-- 							     WHEN maxdia >= 61 THEN '4- ENTRE 61 Y 90'
-- 							     WHEN maxdia >= 31 THEN '3- ENTRE 31 Y 60'
-- 							     WHEN maxdia >= 1 THEN '2- 1 A 30'
-- 							     WHEN maxdia <= 0 THEN '1- CORRIENTE'
-- 								ELSE '0' END AS rango
-- 							FROM (
-- 							 SELECT max(Ciclo.fecha_preparacion::date-(fecha_vencimiento)) as maxdia
-- 							 FROM con.foto_ciclo_pagos fra
-- 							 WHERE fra.dstrct = 'FINV'
-- 								  AND fra.valor_saldo > 0
-- 								  AND fra.reg_status = ''
-- 								  AND fra.negasoc = CarteraExtracto.negocio
-- 								  AND fra.tipo_documento in ('FAC','NDC')
-- 								  AND substring(fra.documento,1,2) not in ('CP','FF','DF')
-- 								  AND fra.fecha_vencimiento <= Ciclo.fecha_fin
-- 								  AND fra.periodo_lote = periodoasignacion
-- 							 GROUP BY negasoc
--
-- 							) vencimiento;


--				CarteraExtracto.venc_mayor = vencimiento_mayor;

			raise notice 'LOOP EXTERNO';

		RETURN NEXT CarteraExtracto;

	END LOOP;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_exportar_extracto_micro_ciclo_pagos(numeric, numeric, numeric)
  OWNER TO postgres;
