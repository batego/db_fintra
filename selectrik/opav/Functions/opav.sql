-- Function: opav.actualiza_descripcion_insumo(integer, character varying)

-- DROP FUNCTION opav.actualiza_descripcion_insumo(integer, character varying);

CREATE OR REPLACE FUNCTION opav.actualiza_descripcion_insumo(subcategoria integer, nom_subcategoria character varying)
  RETURNS text AS
$BODY$
declare
    mensaje text;
    reg record;
    reg1 record;
    _descripcion text;
    coma text:='';

begin


FOR reg IN

	select
		id
	from
		opav.sl_insumo
	where
		id_subcategoria=subcategoria
		and reg_status!='A'
	order by id

LOOP

	_descripcion:=nom_subcategoria||' ';
	coma:='';


	FOR reg1 IN

		select valor_especificacion from opav.sl_esp_insumo where id_material=reg.id

	LOOP

		_descripcion:=_descripcion||coma||reg1.valor_especificacion;
		coma:=' ';

	END LOOP;

	update opav.sl_insumo set descripcion=_descripcion where id=reg.id;

END LOOP;


  return _descripcion;


end;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.actualiza_descripcion_insumo(integer, character varying)
  OWNER TO postgres;
