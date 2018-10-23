-- Function: valida_tasa_cliente(text)

-- DROP FUNCTION valida_tasa_cliente(text);

CREATE OR REPLACE FUNCTION valida_tasa_cliente(text)
  RETURNS text AS
$BODY$Declare
  varpar ALIAS FOR $1;
  neg text;
  resp TEXT;
   id TEXT;

begin

	select into resp id_cliente_padre
	from opav.ofertas o inner join opav.subclientes_eca sc on(o.id_cliente =sc.id_subcliente)
	where id_solicitud=$1 and id_cliente_padre in('CL11479','CL09437','CL18846','CL20138','CL15483','CL20062','CL18846');

        IF resp is not  null
        THEN
        resp:= '1.5';
        end if;

	RETURN resp;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION valida_tasa_cliente(text)
  OWNER TO postgres;
