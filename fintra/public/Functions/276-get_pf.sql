-- Function: get_pf(text)

-- DROP FUNCTION get_pf(text);

CREATE OR REPLACE FUNCTION get_pf(text)
  RETURNS text AS
$BODY$DECLARE
  codFactura ALIAS FOR $1;
  pf TEXT;
BEGIN
  --
  SELECT INTO pf doc
  FROM
                (SELECT CASE WHEN cuenta IN ('16252003') THEN documento_rel ELSE ' ' END AS doc
                FROM con.comprodet where numdoc = codFactura) d
  WHERE
                doc != ' '
                LIMIT 1;

  RETURN pf;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_pf(text)
  OWNER TO postgres;
