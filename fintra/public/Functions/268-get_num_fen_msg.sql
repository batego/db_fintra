-- Function: get_num_fen_msg()

-- DROP FUNCTION get_num_fen_msg();

CREATE OR REPLACE FUNCTION get_num_fen_msg()
  RETURNS text AS
$BODY$DECLARE

  num INTEGER;
BEGIN
	SELECT INTO num last_number AS numx
	FROM series
	WHERE document_type='FEN'	 	;
	UPDATE series SET last_number =last_number +1  WHERE document_type='FEN'	;
  RETURN num;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_num_fen_msg()
  OWNER TO postgres;
COMMENT ON FUNCTION get_num_fen_msg() IS 'secuencia para archivo para mensajes de fenalco';
