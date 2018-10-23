-- Function: get_consecutivo(text, text, text, text)

-- DROP FUNCTION get_consecutivo(text, text, text, text);

CREATE OR REPLACE FUNCTION get_consecutivo(text, text, text, text)
  RETURNS text AS
$BODY$DECLARE
  codigo ALIAS FOR $1;
  anioo ALIAS FOR $2;
  mess ALIAS FOR $3;
  diaa ALIAS FOR $4;
  cons TEXT ='';
  num NUMERIC;

BEGIN

  SELECT INTO cons numero
  FROM consecutivo
  WHERE tipodoc = codigo AND anioo = anio AND mess = mes AND diaa = dia;

  if cons is null then
	--cons:= 'ACEPTADO';
	SELECT INTO num max(numero)+1
        FROM consecutivo
	WHERE tipodoc = codigo;

	INSERT INTO consecutivo (tipodoc,anio,mes,dia,numero) values (codigo,anioo,mess,diaa,num);
	cons:= num;
  end if;

  RETURN cons;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_consecutivo(text, text, text, text)
  OWNER TO postgres;
COMMENT ON FUNCTION get_consecutivo(text, text, text, text) IS 'Genera un consecutivo para los informes presentados a la fiducia basado en el tipodoc y la fecha(aaaa,mm,dd)';
