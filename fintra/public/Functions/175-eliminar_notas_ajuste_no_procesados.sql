-- Function: eliminar_notas_ajuste_no_procesados()

-- DROP FUNCTION eliminar_notas_ajuste_no_procesados();

CREATE OR REPLACE FUNCTION eliminar_notas_ajuste_no_procesados()
  RETURNS text AS
$BODY$DECLARE
  algo int;
BEGIN
		SELECT INTO algo COUNT(oid) FROM ias_fenalco WHERE procesado='NO';
		DELETE FROM ias_fenalco WHERE procesado='NO';
RETURN 'Se elminaron '||algo||' registros';
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eliminar_notas_ajuste_no_procesados()
  OWNER TO postgres;
