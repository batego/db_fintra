-- Function: dv_cuota_actual(character varying)

-- DROP FUNCTION dv_cuota_actual(character varying);

CREATE OR REPLACE FUNCTION dv_cuota_actual(business character varying)
  RETURNS text AS
$BODY$

DECLARE

	nro_cuota varchar;

BEGIN
	SELECT INTO nro_cuota item FROM documentos_neg_aceptado  WHERE cod_neg = business AND replace(substring(fecha,1,7),'-','') = replace(substring(now(),1,7),'-','');

	RETURN nro_cuota::varchar;

	raise notice 'Negocio: %', business;


	IF NOT FOUND  THEN

		nro_cuota:='Pagado';

	END IF;

	return nro_cuota;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION dv_cuota_actual(character varying)
  OWNER TO postgres;
