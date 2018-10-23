-- Function: opav.ws_get_iva_aiu(character varying)

-- DROP FUNCTION opav.ws_get_iva_aiu(character varying);

CREATE OR REPLACE FUNCTION opav.ws_get_iva_aiu(num_os_ character varying)
  RETURNS text AS
$BODY$
DECLARE

 _id_accion 		numeric 		:=0;
 _tipo_modulo 		numeric 		:=0;
 _aiu 			numeric 		:=0;
_rec_ofe		record 			;

BEGIN

	--Se verifica si pertenece al nuevo aplicativo.
	select
		* into _rec_ofe
	from
		opav.ofertas where num_os =  num_os_;


	IF(_rec_ofe.nuevo_modulo = 1) THEN
		--se obtiene el id_accion que pertenece la solicitud.
		select id_accion into _id_accion from opav.acciones where accion_principal = 1 and id_solicitud = _rec_ofe.id_solicitud;

		--se obtiene si lleva iva o aiu pasando por parametro el id_accion obtenido anteriormente.
		SELECT sum(perc_administracion + perc_imprevisto + perc_utilidad) into _aiu  FROM opav.sl_cotizacion where id_accion = _id_accion;

	ELSE

		select sum(porc_imprevisto + porc_imprevisto + porc_utilidad) into _aiu from opav.acciones where id_solicitud =_rec_ofe.id_solicitud;

	END IF;


	IF(_aiu>0) THEN
		RETURN 'AIU';
	ELSE
		RETURN 'IVA';
	END IF;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.ws_get_iva_aiu(character varying)
  OWNER TO postgres;
