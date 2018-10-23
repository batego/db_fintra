-- Function: sp_calcularfechapago(character varying, character varying)

-- DROP FUNCTION sp_calcularfechapago(character varying, character varying);

CREATE OR REPLACE FUNCTION sp_calcularfechapago(_fechanegocio character varying, _pagaduria character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE

	Rs record;
	RsConfLibranza record;
	_FechaPagoPlazoCta TEXT := 'OK';
	FechaPago varchar := '';
	Plazo1raCuota varchar := '';
	FechaNegocioCalcular varchar := '';

	_Intervalo varchar := '';
	_Dias integer := 0;

BEGIN
	--select * from pagadurias;
	--select * from configuracion_libranza;

	FOR Rs IN

		select ''::varchar as fch_Pago, ''::varchar as Plz_1Cta

	LOOP

		SELECT INTO RsConfLibranza * FROM configuracion_libranza WHERE id_pagaduria = (SELECT id FROM pagadurias WHERE documento = _Pagaduria);

		--SELECT fecha_pago as fecha FROM con.ciclos_facturacion WHERE fecha_ini >= ('2016-04-15'::date + '30 DAY'::interval)::date LIMIT 4;

		if ( RsConfLibranza.periodo_gracia = 0 ) then
			_Dias = 30;
			_Intervalo = '30 DAY'::varchar;
		else
			_Dias = 30*RsConfLibranza.periodo_gracia;
			--_Intervalo = _Dias||' DAY'::varchar;
			raise notice '_Dias: %', _Dias;
		end if;

		Plazo1raCuota = _Dias::varchar;

		FechaNegocioCalcular = substring(_FechaNegocio,1,8)||RsConfLibranza.dia_pago;
		raise notice 'FechaNegocioCalcular: %', FechaNegocioCalcular;
		raise notice '_FechaNegocio: %', substring(_FechaNegocio,9)::numeric;
		raise notice 'dia_entrega_novedades: %', RsConfLibranza.dia_entrega_novedades::numeric;


		if ( substring(_FechaNegocio,9)::numeric >= RsConfLibranza.dia_entrega_novedades::numeric ) then
			FechaNegocioCalcular = (FechaNegocioCalcular::date + '30 DAY'::interval)::date;

		end if;

		raise notice 'Intervalo: %', _Intervalo;
		raise notice 'FechaNegocioCalcular: %', FechaNegocioCalcular;
		SELECT into FechaPago fecha_pago FROM con.ciclos_facturacion WHERE (FechaNegocioCalcular::date + _Intervalo::interval)::date between fecha_ini and fecha_fin;
		raise notice 'FechaPago: %', FechaPago;

		_FechaPagoPlazoCta = FechaPago||';'||Plazo1raCuota;
		raise notice '_FechaPagoPlazoCta: %', _FechaPagoPlazoCta;
		--RETURN _FechaPagoPlazoCta::varchar;

		Rs.fch_Pago = FechaPago;
		Rs.Plz_1Cta = Plazo1raCuota;

		RETURN NEXT Rs;

	END LOOP;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_calcularfechapago(character varying, character varying)
  OWNER TO postgres;
