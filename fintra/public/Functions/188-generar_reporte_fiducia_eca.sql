-- Function: generar_reporte_fiducia_eca(text)

-- DROP FUNCTION generar_reporte_fiducia_eca(text);

CREATE OR REPLACE FUNCTION generar_reporte_fiducia_eca(text)
  RETURNS text AS
$BODY$DECLARE
    _facs ALIAS FOR $1;
    _archivo TEXT;
    _consulta TEXT;
    _regs RECORD;
BEGIN
	select into _consulta replace(sql_gtxt,'#PARAM#',_facs) from sql_reporte_fiducia where id_reporte='9';
	FOR _regs IN EXECUTE (_consulta) LOOP
		_archivo:=_regs.arch::text;
	END LOOP;
RETURN _archivo;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION generar_reporte_fiducia_eca(text)
  OWNER TO postgres;
