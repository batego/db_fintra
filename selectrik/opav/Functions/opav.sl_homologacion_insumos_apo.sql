-- Function: opav.sl_homologacion_insumos_apo(integer)

-- DROP FUNCTION opav.sl_homologacion_insumos_apo(integer);

CREATE OR REPLACE FUNCTION opav.sl_homologacion_insumos_apo(id_solicitud_ integer)
  RETURNS character varying AS
$BODY$
DECLARE

 _resultado 		character varying 	:='ok';
 _id_accion 		numeric 		:=0;
 _aiu	 		numeric 		:=0;
 _tipo_modulo 		numeric 		:=0;


BEGIN
	--select opav.sl_homologacion_insumos_apo(923780)

	--Se verifica si pertenece al nuevo aplicativo.
	select
		nuevo_modulo into _tipo_modulo
	from
		opav.ofertas where id_solicitud =  id_solicitud_;


	IF(_tipo_modulo = 1) THEN
		--se obtiene el id_accion que pertenece la solicitud.
		select id_accion into _id_accion from opav.acciones where accion_principal = 1 and id_solicitud = id_solicitud_;

		--se obtiene si lleva iva o aiu pasando por parametro el id_accion obtenido anteriormente.
		SELECT sum(perc_administracion + perc_imprevisto + perc_utilidad) into _aiu  FROM opav.sl_cotizacion where id_accion = _id_accion;

	ELSE
		select sum(porc_imprevisto + porc_imprevisto + porc_utilidad) into _aiu from opav.acciones where id_solicitud =id_solicitud_;

	END IF;

	IF (_AIU > 0) THEN
		SELECT INSUMO_APOTEOSYS INTO _resultado FROM opav.sl_homologacion_insumos_apoteosys WHERE ID_TIPO_INSUMO = 1 AND AIU = 1 AND PORC_IVA = 19;
	ELSE
		SELECT INSUMO_APOTEOSYS INTO _resultado FROM opav.sl_homologacion_insumos_apoteosys WHERE ID_TIPO_INSUMO = 1 AND AIU = 0 AND PORC_IVA = 19;
	END IF;

	RETURN _resultado;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sl_homologacion_insumos_apo(integer)
  OWNER TO postgres;
