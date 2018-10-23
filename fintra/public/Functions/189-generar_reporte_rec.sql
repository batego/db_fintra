-- Function: generar_reporte_rec(text, character varying, text)

-- DROP FUNCTION generar_reporte_rec(text, character varying, text);

CREATE OR REPLACE FUNCTION generar_reporte_rec(text, character varying, text)
  RETURNS text AS
$BODY$DECLARE
  _facs ALIAS FOR $1;
  _usuari ALIAS FOR $2;
  _fecha ALIAS FOR $3;
  _respuesta TEXT;
  _consulta TEXT;
  _regs RECORD;
  _archivo TEXT;
BEGIN

	select into _consulta replace(replace(sql_gtxt,'#PARAM#',_facs),'#FECHA#',''''||_fecha||'''') from sql_reporte_fiducia where id_reporte='10';
	FOR _regs IN EXECUTE (_consulta) LOOP
		_archivo:=_regs.arch::text;
	END LOOP;

	INSERT INTO tablagen(
		    reg_status, table_type, table_code, referencia, descripcion,
		    last_update, user_update, creation_date, creation_user, dato)
	    VALUES ('', 'REPFIDECAR', REPLACE(REPLACE(REPLACE(NOW(),'-',''),':',''),'.',''), '', _archivo,
		    '0099-01-01 00:00:00', '', NOW(), _usuari, '');

	EXECUTE('UPDATE con.factura set fec_envio_fiducia='''||_fecha||''' WHERE documento IN('|| _facs ||')');
  SELECT INTO _respuesta ' Proceso terminado.';
RETURN _respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION generar_reporte_rec(text, character varying, text)
  OWNER TO postgres;
