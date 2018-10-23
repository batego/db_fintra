-- Function: opav.sp_deletesolicitud(character varying, character varying, character varying)

-- DROP FUNCTION opav.sp_deletesolicitud(character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION opav.sp_deletesolicitud(_usuario character varying, _idsolicitud character varying, codigosolicitud character varying)
  RETURNS SETOF opav.rs_delete_solicitudes AS
$BODY$

DECLARE

	result opav.rs_delete_solicitudes;

 BEGIN

	DELETE FROM opav.sl_presolicitud_ocs WHERE responsable = _usuario AND id_solicitud = _idsolicitud;
	DELETE FROM opav.sl_solicitud_ocs WHERE cod_solicitud = CodigoSolicitud;

	if ( FOUND ) then
		result.respta = 'POSITIVO';
	else
		result.respta = 'NEGATIVO';
	end if;

	RETURN NEXT result;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_deletesolicitud(character varying, character varying, character varying)
  OWNER TO postgres;
