-- Function: cotizaciones_ficticias_acciones()

-- DROP FUNCTION cotizaciones_ficticias_acciones();

CREATE OR REPLACE FUNCTION cotizaciones_ficticias_acciones()
  RETURNS text AS
$BODY$DECLARE
    _group RECORD;
    _count INTEGER;
    respuesta TEXT;
    codig_cotizacion CHARACTER VARYING;
BEGIN
    FOR _group IN SELECT *
	FROM acciones
	WHERE ((material!=0 OR mano_obra!=0 OR transporte!=0)
	   AND id_accion NOT IN (SELECT id_accion FROM cotizacion WHERE reg_status!='A')) LOOP
		codig_cotizacion:=get_lcod('COTSER');
		INSERT INTO cotizacion(
		    reg_status,  consecutivo, fecha, id_accion, estado,
		    orden_generada, last_update, user_update)
		VALUES ('',  codig_cotizacion, now() , _group.id_accion, 'P',
		    'N', '0099-01-01 00:00:00', '');

		IF (_group.material != 0) THEN
			INSERT INTO cotizaciondets(
				    reg_status,  codigo_material, cantidad, aprobado,
				    cod_cotizacion, fecha, observacion, id_accion)
			    VALUES ('',  'PR000012', _group.material, '',
				    codig_cotizacion, now(), '', _group.id_accion);
		END IF;
		IF (_group.mano_obra != 0) THEN
			INSERT INTO cotizaciondets(
				    reg_status,  codigo_material, cantidad, aprobado,
				    cod_cotizacion, fecha, observacion, id_accion)
			    VALUES ('',  'PR000013', _group.mano_obra, '',
				    codig_cotizacion, now(), '', _group.id_accion);
		END IF;
		IF (_group.transporte != 0) THEN
			INSERT INTO cotizaciondets(
				    reg_status,  codigo_material, cantidad, aprobado,
				    cod_cotizacion, fecha, observacion, id_accion)
			    VALUES ('',  'PR000014', _group.transporte, '',
				    codig_cotizacion, now(), '', _group.id_accion);
		END IF;

    END LOOP;
    SELECT INTO respuesta 'Proceso ejecutado.';
    RETURN respuesta;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION cotizaciones_ficticias_acciones()
  OWNER TO postgres;
