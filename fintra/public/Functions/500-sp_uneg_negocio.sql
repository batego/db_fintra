-- Function: sp_uneg_negocio(character varying)

-- DROP FUNCTION sp_uneg_negocio(character varying);

CREATE OR REPLACE FUNCTION sp_uneg_negocio(business character varying)
  RETURNS text AS
$BODY$

DECLARE

	Unegocio varchar;

BEGIN

	SELECT INTO Unegocio u.id
	FROM rel_unidadnegocio_convenios ru
	INNER JOIN unidad_negocio u ON ( u.id = ru.id_unid_negocio AND u.id IN (1,2,3,4,5,6,7,8,9,11,10,21,22,30,31) )
	WHERE id_convenio = (select id_convenio from negocios where cod_neg = business);

	RETURN Unegocio::varchar;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_uneg_negocio(character varying)
  OWNER TO postgres;
