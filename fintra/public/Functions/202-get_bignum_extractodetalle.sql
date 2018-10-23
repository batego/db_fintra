-- Function: get_bignum_extractodetalle()

-- DROP FUNCTION get_bignum_extractodetalle();

CREATE OR REPLACE FUNCTION get_bignum_extractodetalle()
  RETURNS numeric AS
$BODY$
 DECLARE
 numx numeric;
        BEGIN

	SELECT INTO numx CAST (descripcion AS numeric)
	FROM tablagen
	WHERE table_type='NUM_EXTDET' AND table_code='NUM_EXTDET';

	UPDATE tablagen SET descripcion='' || (numx-1) WHERE table_type='NUM_EXTDET' AND table_code='NUM_EXTDET';

 RETURN numx;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_bignum_extractodetalle()
  OWNER TO postgres;
