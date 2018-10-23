-- Function: validar_factura_conformada(character varying, character varying)

-- DROP FUNCTION validar_factura_conformada(character varying, character varying);

CREATE OR REPLACE FUNCTION validar_factura_conformada(character varying, character varying)
  RETURNS text AS
$BODY$DECLARE
  _id_accion ALIAS FOR $1;
  _factura_contratista ALIAS FOR $2;
  _respuesta character varying ;
  _tem character varying ;
  _contratista character varying ;
BEGIN
	_respuesta:='ok';
	_contratista:='nada';
	--1
	--primero se valida que tiene prefactura y que no tiene cxp de contratista hecha
	SELECT INTO _contratista COALESCE((SELECT contratista FROM opav.acciones WHERE id_accion=_id_accion AND prefactura_contratista!='' AND fecha_factura_contratista_final='0099-01-01 00:00:00' AND reg_status!='A'),'nada');
	IF(_contratista='nada') THEN--debiÃ³ encontrarse la acciÃ³n (su contratista)
		_respuesta:=' accion no tiene prefactura o tiene cxp de contratista hecha o no existe ..';
		RETURN _respuesta;
	END IF;

	--Â¿como hago para saber si ya tiene cxp hecha el contratista?

	_tem :='nada';
	--2
	--segundo se valida que no exista otra accion del mismo contratista con {misma factura_conformada y tiene cxp de contratista hecha}
	SELECT INTO _tem COALESCE((SELECT id_accion FROM opav.acciones WHERE id_accion!=_id_accion AND contratista=_contratista AND factura_contratista=_factura_contratista AND fecha_factura_contratista_final!='0099-01-01 00:00:00' AND reg_Status!='A'),'nada');
	IF (_tem!='nada') THEN --no debio encontrarse
		_respuesta:=' se encontrÃ³ otra accion con mismo contratista y misma factura conformada y con cxp de contratista hecha ..';
		RETURN respuesta;
	END IF;

RETURN _respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION validar_factura_conformada(character varying, character varying)
  OWNER TO postgres;
