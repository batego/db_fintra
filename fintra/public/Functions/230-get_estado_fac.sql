-- Function: get_estado_fac(text, text)

-- DROP FUNCTION get_estado_fac(text, text);

CREATE OR REPLACE FUNCTION get_estado_fac(text, text)
  RETURNS text AS
$BODY$Declare
  varpar ALIAS FOR $1;
  neg text;
  resp TEXT;

begin

	select into resp num_ingreso
	from con.ingreso_detalle
	where factura=varpar
	AND num_ingreso like 'NC%'
	and reg_status !='A';


        IF resp is null
        THEN
        resp:=(select fd.documento from con.factura f INNER JOIN con.factura_detalle fd ON (f.dstrct=fd.dstrct and f.tipo_documento=fd.tipo_documento and fd.documento=f.documento)
		where f.negasoc=$2 and  numero_remesa =$1   and fd.tipo_documento='ND' limit 1);

		IF resp is not null THEN
		resp:= (select  num_ingreso	from con.ingreso_detalle where factura=resp  	AND num_ingreso like 'NC%'and reg_status !='A');
		END IF;



        END IF;


	RETURN resp;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_estado_fac(text, text)
  OWNER TO postgres;
