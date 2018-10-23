-- Function: opav.get_serie_inventario(integer)

-- DROP FUNCTION opav.get_serie_inventario(integer);

CREATE OR REPLACE FUNCTION opav.get_serie_inventario(integer)
  RETURNS text AS
$BODY$

DECLARE

  tipo_movimiento ALIAS FOR $1;
  _tipoMovimiento varchar;
  secuencia TEXT;
  retcod record;

BEGIN

	if ( tipo_movimiento = 1 ) then
		_tipoMovimiento = 'INV_ENTRADA';
	elsif ( tipo_movimiento = 2 ) then
		_tipoMovimiento = 'INV_SALIDA';
	elsif ( tipo_movimiento = 3 ) then
		_tipoMovimiento = 'INV_TRASLADO';
	end if;

	Select into retcod *
	from series
	where document_type = _tipoMovimiento
	and reg_status='';

	secuencia := retcod.prefix||lpad(retcod.last_number, 5, '0');

	UPDATE series set last_number = last_number+1 where document_type = _tipoMovimiento and reg_status = '';

	RETURN secuencia;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.get_serie_inventario(integer)
  OWNER TO postgres;
