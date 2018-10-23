-- Function: recaudo.sp_aplicacionpago_online(character varying, character varying, numeric, character varying, date, integer)

-- DROP FUNCTION recaudo.sp_aplicacionpago_online(character varying, character varying, numeric, character varying, date, integer);

CREATE OR REPLACE FUNCTION recaudo.sp_aplicacionpago_online(_codrop character varying, _cedula character varying, _total_transaccion numeric, _usuario character varying, _fecharecaudo date, _entidadrecaudadora integer)
  RETURNS text AS
$BODY$

DECLARE

	EntidadRecaudo record;
	_nro_transac_cli TEXT :=apicredit.eg_generar_codigo_activacion(20); --serie de la transaccion cambiar esta por prueba o ERR
        prueba numeric;

BEGIN
	--VALIDAMOS QUE PAGO NO SE APLIQUE DOBLE
	IF(EXISTS(SELECT * FROM recaudo.pagos_xaplicar
			WHERE codrop=_codrop AND cedula = _cedula
			AND total_transaccion=_total_transaccion
			AND pago_aplicado='S' AND pago_reversado='N'))THEN

		RETURN 'PAYAPL';
	END IF;

	---CREAR UNA TABLA PARA GUARDAR EL PAGO QUE SE VA APLICAR.
	INSERT INTO recaudo.pagos_xaplicar(
	    codrop, cedula, total_transaccion, fecharecaudo,
	    entidadrecaudadora,nro_transaccion, creation_user)
	VALUES (_codrop, _cedula, _total_transaccion, _fecharecaudo,_entidadrecaudadora ,_nro_transac_cli, _usuario);


	--CONSULTAMOS QUE LA ENTIDAD RECAUDADORA EXISTA
	SELECT INTO EntidadRecaudo * FROM recaudo.entidad_recaudo WHERE codigo_entidad = _entidadrecaudadora AND pago_automatico = 'S';
	IF FOUND THEN
		--..::SUPER EFECTIVO/BALOTO::..
		IF (_entidadrecaudadora =501) THEN


		END IF;

		--..::BANCO DE OCCIDENTE::..
		IF (_entidadrecaudadora =23) THEN


		END IF;

		--..::AGREGAR LAS OTRAS ENTIDADES AQUI::..


		--ACTUALIZAMOS LA TABLA DE PAGO
		UPDATE recaudo.pagos_xaplicar SET pago_aplicado ='S', nro_transaccion=_nro_transac_cli
		WHERE codrop=_codrop AND cedula=_cedula AND pago_aplicado ='N';


		RETURN _nro_transac_cli;
	END IF;


EXCEPTION WHEN OTHERS THEN
	INSERT INTO recaudo.pagos_xaplicar(
	    codrop, cedula, total_transaccion, fecharecaudo,
	    entidadrecaudadora,nro_transaccion, creation_user)
	VALUES (_codrop, _cedula, _total_transaccion, _fecharecaudo,_entidadrecaudadora ,_nro_transac_cli, _usuario);

        RAISE NOTICE 'THE TRANSACTION IS IN AN UNCOMMITTABLE STATE.';

	RETURN _nro_transac_cli;
END;


$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION recaudo.sp_aplicacionpago_online(character varying, character varying, numeric, character varying, date, integer)
  OWNER TO postgres;
