-- Function: dv_dias_standby(character varying, character varying, character varying, character varying)

-- DROP FUNCTION dv_dias_standby(character varying, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION dv_dias_standby(business character varying, actividad_ character varying, concepto1 character varying, concepto2 character varying)
  RETURNS text AS
$BODY$

DECLARE

	dias integer;
	festivos integer;
	fecha1 date;
	fecha2 date;
	diferencia varchar;

BEGIN

	--fecha2:= SELECT max(fecha)::date from negocios_trazabilidad where cod_neg= business and actividad = actividad_2;
	--fecha1:= SELECT max(fecha)::date from negocios_trazabilidad where cod_neg= business and actividad = actividad_1:

	SELECT INTO fecha1 max(fecha)::date from negocios_trazabilidad where cod_neg= business and actividad = actividad_ and concepto = concepto1;

	SELECT INTO fecha2 max(fecha)::date from negocios_trazabilidad where cod_neg= business and actividad = actividad_ and concepto = concepto2;

	dias:=	(fecha2	- fecha1);

        raise notice 'fecha1: %', fecha1;
        raise notice 'fecha2: %', fecha2;

	festivos:=
	(select count(*)
	from fin.dias_festivos
	where festivo = true
	AND fecha between fecha1  AND fecha2);

	diferencia:= dias - festivos;

	/*SELECT INTO Unegocio u.id
	FROM rel_unidadnegocio_convenios ru
	INNER JOIN unidad_negocio u ON ( u.id = ru.id_unid_negocio AND u.id IN (1,2,3,4,5,6,7,8,9,11,10,21,22) )
	WHERE id_convenio = (select id_convenio from negocios where cod_neg = business);
*/

	RETURN diferencia;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION dv_dias_standby(character varying, character varying, character varying, character varying)
  OWNER TO postgres;
