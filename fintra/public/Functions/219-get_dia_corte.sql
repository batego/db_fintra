-- Function: get_dia_corte()

-- DROP FUNCTION get_dia_corte();

CREATE OR REPLACE FUNCTION get_dia_corte()
  RETURNS text AS
$BODY$
declare


dia text;
BEGIN
---obtenemos el dia de corte del periodo actual---


SELECT INTO dia TO_CHAR(TO_TIMESTAMP(SUBSTRING(NOW(),1,4)::NUMERIC || '-' || TO_CHAR(SUBSTRING(REPLACE(NOW(),'-',''),5,2)::NUMERIC,'FM00')
					|| '-01', 'YYYY-MM-DD')- INTERVAL '1 DAYS' , 'YYYY-MM-DD');

RETURN dia;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_dia_corte()
  OWNER TO postgres;
