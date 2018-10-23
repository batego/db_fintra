-- Function: con.interfaz_negocioxdocumento(character varying)

-- DROP FUNCTION con.interfaz_negocioxdocumento(character varying);

CREATE OR REPLACE FUNCTION con.interfaz_negocioxdocumento(_documento character varying)
  RETURNS text AS
$BODY$

DECLARE

 /************************************************
  *DESCRIPCION: ESTA FUNCION RECIBE COMO PARAMETRO EL DOCUMENTO Y DEVUELVE EL CODIGO EL
  *NEGOCIO
  *AUTOR:=@JZAPATA
  *FECHA CREACION:=2017-12-11
  *LAST_UPDATE:=
  *DESCRIPCION DE CAMBIOS Y FECHA
  *
  ************************************************/

DECLARE

_negocio text:='';

BEGIN

	select
	into
		_negocio
		negasoc
	from
		con.factura
	where
		documento=_documento;

	RETURN _negocio;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_negocioxdocumento(character varying)
  OWNER TO postgres;
