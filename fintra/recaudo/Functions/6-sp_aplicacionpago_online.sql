-- Function: recaudo.sp_aplicacionpago_online(character varying, character varying, numeric, character varying, date, integer, character varying)

-- DROP FUNCTION recaudo.sp_aplicacionpago_online(character varying, character varying, numeric, character varying, date, integer, character varying);

CREATE OR REPLACE FUNCTION recaudo.sp_aplicacionpago_online(_codrop character varying, _cedula character varying, _total_transaccion numeric, _usuario character varying, _fecharecaudo date, _entidadrecaudadora integer, _tipo_canal character varying)
  RETURNS text AS
$BODY$

DECLARE

	 EntidadRecaudo record;
	_nro_transac_cli TEXT := NEXTVAL('recaudo.transaccion_pago_online');
        _resultado_pago varchar ='ERR';

BEGIN
	--VALIDAMOS QUE PAGO NO SE APLIQUE DOBLE
-- 	IF(EXISTS(SELECT * FROM recaudo.pagos_xaplicar
-- 			WHERE codrop=_codrop AND cedula = _cedula
-- 			AND total_transaccion=_total_transaccion
-- 			AND pago_aplicado='S' AND pago_reversado='N'))THEN
--
-- 		RETURN 'PAYAPL';
-- 	END IF;

	---CREAR UNA TABLA PARA GUARDAR EL PAGO QUE SE VA APLICAR.
	INSERT INTO recaudo.pagos_xaplicar(
	    codrop, cedula, total_transaccion, fecharecaudo,
	    entidadrecaudadora,nro_transaccion, creation_user,tipo_canal)
	VALUES (_codrop, _cedula, _total_transaccion, _fecharecaudo,_entidadrecaudadora ,_nro_transac_cli, _usuario,_tipo_canal);


	--CONSULTAMOS QUE LA ENTIDAD RECAUDADORA EXISTA
	SELECT INTO EntidadRecaudo * FROM recaudo.entidad_recaudo WHERE codigo_entidad = _entidadrecaudadora AND pago_automatico = 'S';
	IF FOUND THEN

		--LLAMO LA FUNCION DE DE APLICACION DE PAGOS.


		--ACTUALIZAMOS LA TABLA DE PAGO PASAR A HAROLD.
		UPDATE recaudo.pagos_xaplicar SET pago_aplicado ='N', nro_transaccion=_nro_transac_cli
		WHERE codrop=_codrop AND cedula=_cedula AND pago_aplicado ='N';

		--validamos el canal para la respesta
		IF(_tipo_canal ='ATH')THEN
			_resultado_pago :='OK';

		ELSE
			_resultado_pago:=_nro_transac_cli;
		END IF;

	END IF;

	RETURN _resultado_pago;

EXCEPTION WHEN OTHERS THEN
	INSERT INTO recaudo.pagos_xaplicar(
	    codrop, cedula, total_transaccion, fecharecaudo,
	    entidadrecaudadora,nro_transaccion, creation_user,tipo_canal)
	VALUES (_codrop, _cedula, _total_transaccion, _fecharecaudo,_entidadrecaudadora ,_nro_transac_cli, _usuario,_tipo_canal);

        RAISE NOTICE 'THE TRANSACTION IS IN AN UNCOMMITTABLE STATE.';

	RETURN _resultado_pago;
END;


$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION recaudo.sp_aplicacionpago_online(character varying, character varying, numeric, character varying, date, integer, character varying)
  OWNER TO postgres;
