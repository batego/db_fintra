-- Function: sp_nombreunidadnegocio(character varying)

-- DROP FUNCTION sp_nombreunidadnegocio(character varying);

CREATE OR REPLACE FUNCTION sp_nombreunidadnegocio(business character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE

	Unegocio record;

BEGIN
	FOR Unegocio IN

		select id_unid_negocio::integer, descripcion::varchar as nombre_unid_negocio, id_convenio::integer
		from unidad_negocio un, rel_unidadnegocio_convenios ruc
		where un.id = ruc.id_unid_negocio
		and id_convenio = (select id_convenio from negocios where cod_neg = business)
		--and cod_central_riesgo = ''
		and (ref_1 = 'und_proc_ejec' OR ref_4 = 'MIROCREDITO')
	LOOP

		RETURN NEXT Unegocio;

	END LOOP;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_nombreunidadnegocio(character varying)
  OWNER TO postgres;
