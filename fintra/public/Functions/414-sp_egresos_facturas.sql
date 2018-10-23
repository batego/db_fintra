-- Function: sp_egresos_facturas(character varying)

-- DROP FUNCTION sp_egresos_facturas(character varying);

CREATE OR REPLACE FUNCTION sp_egresos_facturas(_documento character varying)
  RETURNS text AS
$BODY$

DECLARE

  salida TEXT:='';
  items integer:=1;
  retcod record;

BEGIN

	FOR retcod IN (SELECT ingdet.num_ingreso||';'||ingdet.valor_ingreso||';'||ing.fecha_consignacion::date||';'||branch_code as info_recaudo
			from con.ingreso_detalle ingdet
			INNER JOIN con.ingreso ing on (ingdet.num_ingreso=ing.num_ingreso)
			where documento =_documento and ingdet.reg_status=''
			)
	LOOP

		raise notice 'retcod.info_recaudo: % items: %',retcod.info_recaudo,items;
		salida:=salida||''||retcod.info_recaudo||';';
		items:=items+1;

	END LOOP;

	return salida;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_egresos_facturas(character varying)
  OWNER TO postgres;
