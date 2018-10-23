-- Function: get_cc(text)

-- DROP FUNCTION get_cc(text);

CREATE OR REPLACE FUNCTION get_cc(text)
  RETURNS text AS
$BODY$DECLARE
  cedv ALIAS FOR $1;
  cedrret TEXT;

BEGIN
  -- Encontrar el nombre de un cliente a partir de su codigo.
  SELECT INTO cedrret cliente.nit
  from usuarios
  inner join cliente on usuarios.nit=cliente.nit
  where usuarios.idusuario=cedv;
  RETURN cedrret;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_cc(text)
  OWNER TO postgres;
