-- Function: public.array_accum(anyelement)

-- DROP FUNCTION  public.array_accum(anyelement)

CREATE OR REPLACE FUNCTION public.array_accum(anyelement)
RETURNS anyarray AS 
$BODY$
aggregate_dummy
$BODY$
LANGUAGE internal VOLATILE;
ALTER FUNCTION public.array_accum (anyelement)
OWNER TO postgres;