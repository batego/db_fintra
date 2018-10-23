-- Function: opav.sl_homologacion_insumos_apo(integer, integer)

-- DROP FUNCTION opav.sl_homologacion_insumos_apo(integer, integer);

CREATE OR REPLACE FUNCTION opav.sl_homologacion_insumos_apo(id_solicitud_ integer, id_tipo_insumo_ integer)
  RETURNS record AS
$BODY$
DECLARE

 _resultado 		record		 	;
 _id_accion 		numeric 		:=0;
 _aiu	 		numeric 		:=0;
 _tipo_modulo 		numeric 		:=0;
 _ocs			record;
 _insumo		character varying 	:='';
 _porc_iva		numeric			:=19;
 _query			text;

BEGIN
	--select opav.sl_homologacion_insumos_apo(923780 , 5 )

	--Se verifica si pertenece al nuevo aplicativo.
	select
		nuevo_modulo into _tipo_modulo
	from
		opav.ofertas_view_dblink where id_solicitud =  id_solicitud_;


	IF(_tipo_modulo = 1) THEN
		--se obtiene el id_accion que pertenece la solicitud.
		select id_accion into _id_accion from opav.acciones where accion_principal = 1 and id_solicitud = id_solicitud_;

		--se obtiene si lleva iva o aiu pasando por parametro el id_accion obtenido anteriormente.
		SELECT sum(perc_administracion + perc_imprevisto + perc_utilidad) into _aiu  FROM opav.sl_cotizacion where id_accion = _id_accion;

	ELSE

		select sum(porc_imprevisto + porc_imprevisto + porc_utilidad) into _aiu from opav.acciones where id_solicitud =id_solicitud_;

	END IF;

	IF(id_tipo_insumo_ = 5) THEN

		_porc_iva = 0;

	END IF;

	IF (_AIU > 0) THEN

		_query := 'SELECT INSUMO_APOTEOSYS , PORC_IVA::numeric(10,3) , insumo_apoteosys FROM opav.sl_homologacion_insumos_apoteosys WHERE ID_TIPO_INSUMO = ' || id_tipo_insumo_ || ' AND AIU = 1  AND PORC_IVA = ' ||_porc_iva;

	ELSE

		_query := 'SELECT INSUMO_APOTEOSYS , PORC_IVA::numeric(10,3) , insumo_apoteosys FROM opav.sl_homologacion_insumos_apoteosys WHERE ID_TIPO_INSUMO = ' || id_tipo_insumo_ || ' AND AIU = 0  AND PORC_IVA = ' ||_porc_iva;

	END IF;

	--raise notice '_query%' , _query;

	FOR 	_resultado	IN

		execute _query

	LOOP

		RETURN  _resultado;

	END LOOP;



END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sl_homologacion_insumos_apo(integer, integer)
  OWNER TO postgres;
