-- Function: tem.tiempo()

-- DROP FUNCTION tem.tiempo();

CREATE OR REPLACE FUNCTION tem.tiempo()
  RETURNS timestamp without time zone AS
$BODY$

DECLARE
BEGIN
--raise notice 'statement_timestamp(): %',statement_timestamp();
	for i in 1..10loop
		--raise notice 'i: % CURRENT_TIME: %',i,CURRENT_TIME;
		--raise notice 'i: % transaction_timestamp(): %',i,transaction_timestamp();
		raise notice ' CURRENT_TIME: %',clock_timestamp() ;
		--raise notice ' i % fecha: %  tiempo en segundos: % tiempo en milesegundos: %',i,CURRENT_TIMESTAMP,EXTRACT(SECOND FROM NOW()),EXTRACT(MILLISECONDS FROM NOW());

        end loop;
        raise notice ' CURRENT_TIME: %',clock_timestamp() ;
        return CURRENT_TIMESTAMP(0);
end;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION tem.tiempo()
  OWNER TO postgres;
