-- Function: opav.sp_aprobarsolicitud(character varying, character varying, character varying, character varying)

-- DROP FUNCTION opav.sp_aprobarsolicitud(character varying, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION opav.sp_aprobarsolicitud(_usuario character varying, _solaprobar character varying, _opcionaccion character varying, _descripcionaprobacion character varying)
  RETURNS SETOF opav.rs_rspta_aprobacion AS
$BODY$

DECLARE

	result opav.rs_rspta_aprobacion;

 BEGIN

	update opav.sl_solicitud_ocs
	set
		aprobar_solicitud = _OpcionAccion,
		usuario_aprobacion = _Usuario,
		razones = _DescripcionAprobacion
	where
		cod_solicitud = _SolAprobar;

	if ( FOUND ) then
		result.respta = 'POSITIVO';
	else
		result.respta = 'NEGATIVO';
	end if;

	RETURN NEXT result;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_aprobarsolicitud(character varying, character varying, character varying, character varying)
  OWNER TO postgres;
