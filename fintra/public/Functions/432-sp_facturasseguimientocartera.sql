-- Function: sp_facturasseguimientocartera(character varying)

-- DROP FUNCTION sp_facturasseguimientocartera(character varying);

CREATE OR REPLACE FUNCTION sp_facturasseguimientocartera(_negocio character varying)
  RETURNS SETOF rs_facturasneg AS
$BODY$

DECLARE

	result rs_FacturasNeg;
	rsBusiness record;

BEGIN

	/*select * from cliente limit 100;*/

	SELECT INTO rsBusiness * FROM negocios WHERE  cod_neg = _Negocio;

	IF FOUND THEN

		FOR result IN

			SELECT
				documento,
				valor_saldo::numeric(15,0)
			FROM con.factura
			WHERE reg_status = ''
			      AND dstrct = 'FINV'
			      AND tipo_documento in ('FAC','NDC')
			      AND replace(substring(fecha_vencimiento,1,7),'-','')::numeric <= replace(substring(now(),1,7),'-','')::numeric
			      AND negasoc = _Negocio

		LOOP

			RETURN NEXT result;

		END LOOP;

	ELSE

		FOR result IN

			SELECT
				documento,
				valor_saldo::numeric(15,0)
			FROM con.foto_cartera_geotech
			WHERE reg_status = ''
			      --and periodo_lote = replace(substring(now()::date,1,7),'-','')
			      and dstrct = 'GEOT'
			      and tipo_documento = 'FACN'
			      and nit = _Negocio
			ORDER BY negasoc

		LOOP

			RETURN NEXT result;

		END LOOP;

	END IF;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_facturasseguimientocartera(character varying)
  OWNER TO postgres;
