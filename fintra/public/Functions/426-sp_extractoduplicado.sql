-- Function: sp_extractoduplicado(character varying, character varying, character varying)

-- DROP FUNCTION sp_extractoduplicado(character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION sp_extractoduplicado(usuario character varying, coduplicado character varying, unidadnegocio character varying)
  RETURNS text AS
$BODY$

DECLARE

	spextracto text:='';

BEGIN

	if ( UnidadNegocio = 'MICROCREDITO' ) then

		spextracto := SP_ExtractoDuplicado_Micro(usuario, CoDuplicado);
	else
		spextracto := SP_ExtractoDuplicado_Fenalco(usuario, CoDuplicado);
	end if;

	RETURN spextracto;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_extractoduplicado(character varying, character varying, character varying)
  OWNER TO postgres;
