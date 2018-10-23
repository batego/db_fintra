-- Function: public.list(text)

-- DROP FUNCTION  public.list(text)

CREATE OR REPLACE FUNCTION public.list(text)
RETURNS text AS 
$BODY$
aggregate_dummy
$BODY$
LANGUAGE internal VOLATILE;
ALTER FUNCTION public.list (text)
OWNER TO postgres;