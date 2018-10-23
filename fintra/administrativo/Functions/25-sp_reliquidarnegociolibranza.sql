-- Function: administrativo.sp_reliquidarnegociolibranza(integer, character varying, numeric, character varying)

-- DROP FUNCTION administrativo.sp_reliquidarnegociolibranza(integer, character varying, numeric, character varying);

CREATE OR REPLACE FUNCTION administrativo.sp_reliquidarnegociolibranza(_numero_solicitud integer, accion character varying, diferencia numeric, _usuario character varying)
  RETURNS text AS
$BODY$

DECLARE

	respuesta varchar := '';
	PermitirProceso varchar;

	RSolAvalNegocioLiq record;
	ValidarDeducciones record;
	DiffAccion numeric;


BEGIN

	--BUSCAMOS INFORMACION DEL NEGOCIO.
	select into RSolAvalNegocioLiq n.*, dna.fecha::date as fecha_pricuota --select n.*, dna.fecha::date as fecha_pricuota
	from solicitud_aval sa
	inner join negocios n on (sa.cod_neg = n.cod_neg)
	inner join documentos_neg_aceptado dna on (n.cod_neg = dna.cod_neg and item = 1)
	where numero_solicitud = _numero_solicitud;

	/*
	create table dna_reliq_libranza as
	SELECT * from documentos_neg_aceptado where cod_neg = 'LB00030' and item = 1; --RSolAval.cod_aval
	select * from dna_reliq_libranza
	*/

	if ( accion = 'MAYOR' ) then
		DiffAccion = RSolAvalNegocioLiq.vr_desembolso + diferencia;
	else
		DiffAccion = RSolAvalNegocioLiq.vr_desembolso; --   - diferencia;
	end if;

	--IDENTIFICO LAS CANTIDADES DE CARTERAS A COMPRAR Y LA SUMA.
	SELECT INTO ValidarDeducciones count(0) as cta_obligaciones, sum(valor_comprar) as sum_obligaciones FROM solicitud_obligaciones_comprar WHERE numero_solicitud = _numero_solicitud AND valor_comprar != 0;

	--DETERMINAR SI LAS OBLIGACIONES COMPRADAS SUPERAN LO PERMITIDO
	--select into PermitirProceso SP_DesembolsoDeducciones('CHEQUE', 'T', 1, _numero_solicitud, ValidarDeducciones.sum_obligaciones, ValidarDeducciones.cta_obligaciones);
	select into PermitirProceso valida_cuota_libranza(_numero_solicitud, DiffAccion);
	raise notice 'PermitirProceso: %, DiffAccion: %', PermitirProceso, DiffAccion;

	IF ( PermitirProceso = 'OK' ) THEN

		if ( accion = 'MAYOR' ) then

			--ACTUALIZAMOS ESTADO/ACTIVIDAD DEL NEGOCIO
			UPDATE negocios SET actividad = 'RAD', estado_neg = 'P', vr_desembolso = DiffAccion, vr_negocio = DiffAccion WHERE cod_neg = RSolAvalNegocioLiq.cod_neg;
			UPDATE solicitud_aval SET valor_solicitado = DiffAccion WHERE numero_solicitud = _numero_solicitud;

			--INSERTAMOS TRAZABILIDAD
			INSERT INTO negocios_trazabilidad(
				    reg_status, dstrct, numero_solicitud, actividad, usuario, fecha,
				    cod_neg, comentarios, concepto, causal, comentario_stby)
			    VALUES ('', 'FINV', _numero_solicitud, 'RAD', _usuario, now(),
				    RSolAvalNegocioLiq.cod_neg, 'PASA A REFERENCIACION PARA VERIFICAR EL NEGOCIO - POR CAMBIOS EN LA COMPRA DE CARTERA', 'CONTINUA', '', '');

			--COPIA DE LA LIQUIDACION ACTUAL
			INSERT INTO dna_reliq_libranza (
				cod_neg,
				item, fecha, dias, saldo_inicial, capital, interes, valor, saldo_final,
				reg_status, creation_date, no_aval, capacitacion, cat, seguro, interes_causado,
				fch_interes_causado, documento_cat, custodia, remesa, causar, dstrct, tipo, cuota_manejo
				)
			SELECT
				cod_neg,
				item, fecha, dias, saldo_inicial, capital, interes, valor, saldo_final,
				reg_status, now(), no_aval, capacitacion, cat, seguro, interes_causado,
				fch_interes_causado, documento_cat, custodia, remesa, causar, dstrct, tipo, cuota_manejo
				FROM documentos_neg_aceptado
				WHERE cod_neg = RSolAvalNegocioLiq.cod_neg
				ORDER BY item::numeric;

			IF FOUND THEN

				--BORRAMOS LA LIQUIDACION ACTUAL.
				DELETE FROM documentos_neg_aceptado WHERE cod_neg = RSolAvalNegocioLiq.cod_neg;
				raise notice 'cod_neg: %', RSolAvalNegocioLiq.cod_neg;

				--RELIQUIDAMOS EL NEGOCIO CON LA NUEVA BASE
				INSERT INTO documentos_neg_aceptado (
					cod_neg,
					item, fecha, dias, saldo_inicial, capital, interes, valor, saldo_final,
					reg_status, creation_date, no_aval, capacitacion, cat, seguro, interes_causado,
					fch_interes_causado, documento_cat, custodia, remesa, causar, dstrct, tipo, cuota_manejo
					)
				SELECT
					RSolAvalNegocioLiq.cod_neg as cod_neg,
					item, fecha, dias, saldo_inicial, capital, interes, valor, saldo_final,
					'', now()::date, 0, capacitacion, cat, seguro, 0,
					null, '', 0, 0, 'S', '', tipo, cuota_manejo
				--FROM fn_liquidacion_libranza ('PRINCIPAL', 7300000::NUMERIC, 30::INTEGER, '38', 'CTFCPV', '2016-05-13'::DATE, '2016-07-12'::DATE);
				FROM fn_liquidacion_libranza ('PRINCIPAL', DiffAccion, RSolAvalNegocioLiq.nro_docs::INTEGER, '38', 'CTFCPV', RSolAvalNegocioLiq.fecha_negocio::date, RSolAvalNegocioLiq.fecha_pricuota);

				IF FOUND THEN
					respuesta = 'OK';
				END IF;

			END IF;
		else
			respuesta = 'OK';
		end if;
	ELSE
		respuesta = 'RECALCULAR';
	END IF;

	return respuesta;

end;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION administrativo.sp_reliquidarnegociolibranza(integer, character varying, numeric, character varying)
  OWNER TO postgres;
