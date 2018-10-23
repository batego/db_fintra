-- Function: get_valor_credito(text)

-- DROP FUNCTION get_valor_credito(text);

CREATE OR REPLACE FUNCTION get_valor_credito(text)
  RETURNS text AS
$BODY$Declare
  codigo_negocio ALIAS FOR $1;
  valor TEXT;
begin

	select into valor valor_credito
	from con.comprodet
	where numdoc = codigo_negocio and
		cuenta = '23352001' Limit 1;
	RETURN valor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_valor_credito(text)
  OWNER TO postgres;
COMMENT ON FUNCTION get_valor_credito(text) IS 'Retorna el valor_credito de la cuenta 23352001 de un negocio dado';
