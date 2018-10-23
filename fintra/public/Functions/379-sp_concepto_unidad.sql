-- Function: sp_concepto_unidad(numeric, character varying)

-- DROP FUNCTION sp_concepto_unidad(numeric, character varying);

CREATE OR REPLACE FUNCTION sp_concepto_unidad(uneg numeric, categ character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE

	concepto_unidad record;

BEGIN

	SELECT INTO concepto_unidad id::integer, descripcion::varchar
	FROM conceptos_recaudo
	WHERE dias_rango_ini > 0
	AND prefijo not in ('CG','FG','PG','CH')
	AND id_unidad_negocio = uneg
	AND categoria = categ;

	--raise notice 'id: %, descripcion: %', concepto_unidad.id, concepto_unidad.descripcion;

	RETURN NEXT concepto_unidad;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_concepto_unidad(numeric, character varying)
  OWNER TO postgres;
