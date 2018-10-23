-- Function: sp_rescarteraconsolidadohijos(numeric, character varying, character varying)

-- DROP FUNCTION sp_rescarteraconsolidadohijos(numeric, character varying, character varying);

CREATE OR REPLACE FUNCTION sp_rescarteraconsolidadohijos(periodoasignacion numeric, unidadnegocio character varying, bussneg character varying)
  RETURNS text AS
$BODY$

DECLARE

	CarteraHijos record;
	ReturnNumeric numeric := 0;

BEGIN

	IF ( UnidadNegocio not in (1,6,7) ) THEN

		select into CarteraHijos sum(valor_saldo)::numeric as valor_asignado
		from con.foto_cartera f
		where periodo_lote = PeriodoAsignacion
			and valor_saldo > 0
			and reg_status = ''
			and dstrct = 'FINV'
			and tipo_documento in ('FAC','NDC')
			and substring(documento,1,2) not in ('CP','FF','DF')
			and negasoc in (SELECT cod_neg from negocios where negocio_rel = BussNeg);
			--and replace(substring(f.fecha_vencimiento,1,7),'-','')::numeric <= PeriodoAsignacion;
		IF FOUND THEN
			ReturnNumeric = ReturnNumeric + coalesce(CarteraHijos.valor_asignado,0);
			raise notice 'ReturnNumeric en AVAL: %', ReturnNumeric;
		END IF;
	END IF;

	IF ( UnidadNegocio = 3 ) THEN

		select into CarteraHijos sum(valor_saldo)::numeric as valor_asignado
		from con.foto_cartera f
		where periodo_lote = PeriodoAsignacion
			and valor_saldo > 0
			and reg_status = ''
			and dstrct = 'FINV'
			and tipo_documento in ('FAC','NDC')
			and substring(documento,1,2) not in ('CP','FF','DF')
			and negasoc in (SELECT cod_neg from negocios where negocio_rel_seguro = BussNeg);
			--and replace(substring(f.fecha_vencimiento,1,7),'-','')::numeric <= PeriodoAsignacion;
		IF FOUND THEN
			ReturnNumeric = ReturnNumeric + coalesce(CarteraHijos.valor_asignado,0);
			raise notice 'ReturnNumeric en SEGURO: %', ReturnNumeric;
		END IF;

		select into CarteraHijos sum(valor_saldo)::numeric as valor_asignado
		from con.foto_cartera f
		where periodo_lote = PeriodoAsignacion
			and valor_saldo > 0
			and reg_status = ''
			and dstrct = 'FINV'
			and tipo_documento in ('FAC','NDC')
			and substring(documento,1,2) not in ('CP','FF','DF')
			and negasoc in (SELECT cod_neg from negocios where negocio_rel_gps = BussNeg);
			--and replace(substring(f.fecha_vencimiento,1,7),'-','')::numeric <= PeriodoAsignacion;
		IF FOUND THEN
			ReturnNumeric = ReturnNumeric + coalesce(CarteraHijos.valor_asignado,0);
			raise notice 'ReturnNumeric en GPS: %', ReturnNumeric;
		END IF;
	END IF;

	RETURN ReturnNumeric;



END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_rescarteraconsolidadohijos(numeric, character varying, character varying)
  OWNER TO postgres;
