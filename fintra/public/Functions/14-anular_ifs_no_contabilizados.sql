-- Function: anular_ifs_no_contabilizados(text)

-- DROP FUNCTION anular_ifs_no_contabilizados(text);

CREATE OR REPLACE FUNCTION anular_ifs_no_contabilizados(text)
  RETURNS text AS
$BODY$DECLARE
  _codneg ALIAS FOR $1;
  _respuesta TEXT;
BEGIN
  _respuesta:='xx';
  UPDATE ing_fenalco SET reg_status='A',usuario_anulacion='ADMIN',fecha_anulacion=NOW() WHERE codneg=_codneg AND fecha_contabilizacion='0099-01-01 00:00:00' AND reg_status!='A';
  _respuesta:='Proceso ejecutado.'	;
RETURN _respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION anular_ifs_no_contabilizados(text)
  OWNER TO postgres;
