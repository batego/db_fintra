-- Function: get_nombreusuario(text)

-- DROP FUNCTION get_nombreusuario(text);

CREATE OR REPLACE FUNCTION get_nombreusuario(text)
  RETURNS text AS
$BODY$DECLARE
  loginUsuario ALIAS FOR $1;
  nomUsuario TEXT;

BEGIN
  -- Encontrar el nombre de un usuario a partir de su id de usuario.
  SELECT INTO nomUsuario nombre
  FROM usuarios
  WHERE idusuario = UPPER(loginUsuario);

  RETURN nomUsuario;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_nombreusuario(text)
  OWNER TO postgres;
