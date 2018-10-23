-- Function: aprobar_desaprobar_cxp(character varying, character varying, character varying, character varying)

-- DROP FUNCTION aprobar_desaprobar_cxp(character varying, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION aprobar_desaprobar_cxp(character varying, character varying, character varying, character varying)
  RETURNS text AS
$BODY$DECLARE
  _documento ALIAS FOR $1;
  _proveedor ALIAS FOR $2;
  _negocio ALIAS FOR $3;
  _estado ALIAS FOR $4;
  respuesta TEXT;
  _aprobadorx character(15);
BEGIN
IF (UPPER(_estado)='S') THEN
	_aprobadorx='JGOMEZ';
END IF;
IF (UPPER(_estado)='N') THEN
	_aprobadorx='';
END IF;
IF (UPPER(_estado)='S' OR UPPER(_estado)='N') THEN
  UPDATE fin.cxp_doc
  SET aprobador=_aprobadorx
  WHERE dstrct='FINV' AND proveedor=_proveedor AND tipo_documento='FAP' AND documento=_documento AND documento_relacionado=_negocio
	AND SUBSTR(documento,1,2)='FP' AND SUBSTR(documento_relacionado,1,2)='NG'  ;
END IF;
  SELECT INTO respuesta ' ModificaciÃ³n terminada.';
RETURN respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION aprobar_desaprobar_cxp(character varying, character varying, character varying, character varying)
  OWNER TO postgres;
