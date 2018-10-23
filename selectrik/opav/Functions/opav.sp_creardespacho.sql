-- Function: opav.sp_creardespacho(character varying, character varying, character varying, character varying, character varying, character varying)

-- DROP FUNCTION opav.sp_creardespacho(character varying, character varying, character varying, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION opav.sp_creardespacho(_usuario character varying, _ordencompra character varying, _proveedor character varying, _descripcion character varying, _fechaentrega character varying, _direccionentrega character varying)
  RETURNS SETOF opav.rs_ordencs AS
$BODY$

DECLARE

	result opav.rs_OrdenCS;

	Sepuede integer;

	DSPCH varchar;

BEGIN

	result.resultado_accion = 'NEGATIVO';

	DSPCH := opav.get_lote_despacho('DESPACHO_NO');

	INSERT INTO opav.sl_despacho_ocs(
		    reg_status, dstrct, cod_despacho, cod_ocs, cod_proveedor,
		    responsable, direccion_entrega, descripcion, fecha_actual, fecha_entrega,
		    estado_despacho, creation_date, creation_user, last_update,
		    user_update)

	    VALUES ('', 'FINV', DSPCH, _OrdenCompra, _Proveedor,
		    _usuario, _DireccionEntrega, _Descripcion, now(), now(),
		    0, now(), _usuario, now(), _usuario);

	IF FOUND THEN

		result.resultado_accion = DSPCH;

	END IF;

	RETURN NEXT result;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_creardespacho(character varying, character varying, character varying, character varying, character varying, character varying)
  OWNER TO postgres;
