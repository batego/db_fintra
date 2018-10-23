-- Function: get_cxp_doc(text, text)

-- DROP FUNCTION get_cxp_doc(text, text);

CREATE OR REPLACE FUNCTION get_cxp_doc(text, text)
  RETURNS text AS
$BODY$DECLARE
  docu ALIAS FOR $1;
  trans ALIAS FOR $2;
  doc_cxp TEXT;

BEGIN
  -- Encontrar la cxp_doc relacionada a un egreso.
  SELECT INTO doc_cxp documento
  FROM    egreso e
	INNER JOIN egresodet d ON (e.transaccion = d.transaccion AND e.document_no = d.document_no)
  WHERE
	e.document_no = docu
	AND e.transaccion = trans
  LIMIT 1;

  RETURN doc_cxp;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_cxp_doc(text, text)
  OWNER TO postgres;
