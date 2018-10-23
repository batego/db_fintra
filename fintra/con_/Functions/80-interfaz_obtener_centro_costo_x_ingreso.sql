-- Function: con.interfaz_obtener_centro_costo_x_ingreso(character varying, integer)

-- DROP FUNCTION con.interfaz_obtener_centro_costo_x_ingreso(character varying, integer);

CREATE OR REPLACE FUNCTION con.interfaz_obtener_centro_costo_x_ingreso(num_ingreso_ character varying, opcion_ integer)
  RETURNS text AS
$BODY$

DECLARE

  centroCosto TEXT;
  negocio text;
  dato text;

BEGIN

	select into centroCosto, negocio
		CON.OBTENER_HOMOLOGACION_APOTEOSYS('RECAUDO_S_E', 'CC', sp_uneg_negocio_name(fac.negasoc),con.agencia, 2) as cu,
		fac.negasoc
	from
		con.ingreso_detalle ing
	inner join
		con.factura fac on(fac.tipo_documento=ing.tipo_doc and fac.documento=ing.documento)
	inner join
		negocios neg on(neg.cod_neg=fac.negasoc)
	inner join
		convenios con on(con.id_convenio=neg.id_convenio)
	where
		num_ingreso=num_ingreso_
	group by
		fac.negasoc, con.agencia;

	if(opcion_=1)then
		dato:=centroCosto;
	elsif(opcion_=2)then
		dato:=negocio;
	end if;

RETURN dato;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_obtener_centro_costo_x_ingreso(character varying, integer)
  OWNER TO postgres;
