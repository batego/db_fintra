-- Function: eliminar_codeudor(text)

-- DROP FUNCTION eliminar_codeudor(text);

CREATE OR REPLACE FUNCTION eliminar_codeudor(id_cod text)
  RETURNS text AS
$BODY$DECLARE
	nom_usuario TEXT;
	ret TEXT;
BEGIN
	SELECT INTO nom_usuario nombre FROM codeudor where id=id_cod;
	DELETE FROM codeudor where id=id_cod;
	if nom_usuario IS NOT NULL THEN
		ret:='El codeudor '||nom_usuario||' fue eliminado correctamente';
	else
		ret:='No hay codeudor con esa identificacion';
	end if;
	RETURN ret;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eliminar_codeudor(text)
  OWNER TO postgres;
