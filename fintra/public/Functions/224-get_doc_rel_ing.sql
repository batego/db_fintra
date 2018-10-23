-- Function: get_doc_rel_ing(text)

-- DROP FUNCTION get_doc_rel_ing(text);

CREATE OR REPLACE FUNCTION get_doc_rel_ing(text)
  RETURNS text AS
$BODY$DECLARE
  numIng ALIAS FOR $1;
  docRel TEXT;

BEGIN
  docRel = '';
  SELECT INTO docRel documento_rel
  FROM con.comprodet
  WHERE
	numdoc = numIng
	and valor_credito > 0
	and documento_rel !='';

  RETURN docRel;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_doc_rel_ing(text)
  OWNER TO postgres;
COMMENT ON FUNCTION get_doc_rel_ing(text) IS 'Obtener el documento relacionado.';
