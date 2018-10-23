-- Function: tem.getnitproveedor(character varying, character varying, character varying)

-- DROP FUNCTION tem.getnitproveedor(character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION tem.getnitproveedor(_descripcion character varying, _proveedor_final character varying, _proveedor character varying)
  RETURNS text AS
$BODY$
DECLARE

BEGIN

	IF( _DESCRIPCION ILIKE 'APLICA FORMULA DE LA ACCION%')THEN
		return _proveedor_final;
	END IF;

	IF( _DESCRIPCION ILIKE 'APLICA FACTORING DE LA ACCION%')THEN
		return _proveedor_final;
	END IF;

	return _proveedor;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION tem.getnitproveedor(character varying, character varying, character varying)
  OWNER TO postgres;
