-- Function: opav.sp_verificarpreocs(character varying)

-- DROP FUNCTION opav.sp_verificarpreocs(character varying);

CREATE OR REPLACE FUNCTION opav.sp_verificarpreocs(usuario character varying)
  RETURNS SETOF opav.rs_verify_preocs AS
$BODY$

DECLARE

	result opav.rs_verify_preocs;
	rsInfoPreOCS record;

	Sepuede integer;

	LoteOCS varchar := '';

 BEGIN

	result.respta = 'NEGATIVO';

	--select responsable, cod_solicitud, estado_preocs from opav.sl_preocs group by responsable, cod_solicitud, estado_preocs
	select into Sepuede count(0)
	from (
		select responsable, cod_solicitud, estado_preocs
		from opav.sl_preocs
		where responsable = Usuario and estado_preocs = 0
		group by responsable, cod_solicitud, estado_preocs
	) c;

	raise notice 'Sepuede: %',Sepuede;

	if ( Sepuede > 0 ) then

		result.respta = 'POSITIVO';

	else

		result.respta = 'NEGATIVO';

	end if;

	RETURN NEXT result;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sp_verificarpreocs(character varying)
  OWNER TO postgres;
