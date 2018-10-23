-- Function: get_departamento(text)

-- DROP FUNCTION get_departamento(text);

CREATE OR REPLACE FUNCTION get_departamento(text)
  RETURNS text AS
$BODY$
declare

    detartamento text;


/*
Retorna el depatamento de una ciudad jpinedo
*/
begin

	select into detartamento department_name from estado inner join  ciudad c on ( department_code=c.coddpt)
	where c.codciu=$1;


    return detartamento::text;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_departamento(text)
  OWNER TO postgres;
