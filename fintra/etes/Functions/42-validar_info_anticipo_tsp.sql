-- Function: etes.validar_info_anticipo_tsp(text, text, text, text)

-- DROP FUNCTION etes.validar_info_anticipo_tsp(text, text, text, text);

CREATE OR REPLACE FUNCTION etes.validar_info_anticipo_tsp(cedula_conductor text, placa text, manifiesto text, login text)
  RETURNS SETOF etes.rs_anticipo_gasolina AS
$BODY$
DECLARE
retorno etes.rs_anticipo_gasolina ;
BEGIN

	--1.)Validamos login descuento...
	PERFORM * FROM login_estacion_descuento WHERE loginx=login;
	IF FOUND THEN

		--2.)Validamos si es anticipo 2
		raise notice 'entro descuento login';

                select into retorno *
		,(a.vlr-(((get_porcentaje_descuento_gasolina('ELVENADO',a.agency_id))/100)*a.vlr)) AS vlr_neto_real, --disponible
		'ANTICIPO2'::VARCHAR AS tipo_anticipo_busqueda
		FROM 	fin.anticipos_pagos_terceros_tsp a
		WHERE cedcon= cedula_conductor --parametro cedula conductor
		AND UPPER(supplier) = UPPER(placa)--parametro placa
		AND planilla= manifiesto --parametro planilla
		AND estado_pago_tercero = ''
		AND tipo_anticipo = 'FINTRAGASOLINA'
		and fecha_autorizacion='0099-01-01 00:00:00'::timestamp --para verificar que este disponible
		and user_autorizacion='' --para verificar que este disponible
		AND reg_status != 'A';

		if(not FOUND )then

			--3.)Validamos si es anticipo 3	es decir si una estacion tomo el anticipo la otra no la puede tomar
			raise notice 'No es anticipo 2';
			select into retorno a.*,
			(a.vlr_neto-(vlr_gasolina+vlr_efectivo)) AS vlr_neto_real,  --disponible
			'ANTICIPO3'::VARCHAR AS tipo_anticipo_busqueda
			FROM fin.anticipos_pagos_terceros_tsp a,estacion_gasolina b
			WHERE cedcon=cedula_conductor --parametro cedula conductor
			AND UPPER(supplier) = UPPER(placa)--parametro placa
			AND planilla = manifiesto  --parametro planilla
			AND estado_pago_tercero != ''
			AND tipo_anticipo = 'FINTRAGASOLINA'
			AND a.reg_status != 'A';
			if(not FOUND )then
				retorno.tipo_anticipo_busqueda:='NOENCONTRADO';
			END IF;

		end if;
	else
		retorno.tipo_anticipo_busqueda:='ERRORLOGIN';
	eND IF;

RETURN next retorno;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.validar_info_anticipo_tsp(text, text, text, text)
  OWNER TO postgres;
