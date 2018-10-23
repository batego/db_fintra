-- Function: recaudo.sp_reversarpago_online(character varying, character varying, character varying, integer)

-- DROP FUNCTION recaudo.sp_reversarpago_online(character varying, character varying, character varying, integer);

CREATE OR REPLACE FUNCTION recaudo.sp_reversarpago_online(_nro_transac_cli character varying, _cod_motivo character varying, _usuario character varying, _entidadrecaudadora integer)
  RETURNS text AS
$BODY$

DECLARE

	EntidadRecaudo record;
	retorno varchar := 'OK';

BEGIN

	--VALIDAMOS EL NUMERO DE TRANSACCION
	IF(NOT EXISTS(SELECT * FROM recaudo.pagos_xaplicar WHERE nro_transaccion=_nro_transac_cli  AND pago_aplicado ='S' ))THEN
		RETURN 'ERR';
	END IF;

	IF(EXISTS(SELECT * FROM recaudo.pagos_xaplicar WHERE nro_transaccion=_nro_transac_cli  AND pago_reversado ='S' ))THEN
		RETURN 'PAYREV';
	END IF;

	---CREAR UNA TABLA PARA GUARDAR LA REVERSION DEL PAGO.
	INSERT INTO recaudo.pagos_xreversar(entidadrecaudadora,nro_transaccion,cod_motivo,creation_user )
	VALUES (_entidadrecaudadora,_nro_transac_cli,_cod_motivo,_usuario);

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
		UPDATE recaudo.pagos_xaplicar SET pago_reversado ='S', last_update=now(), user_update=_usuario
		WHERE nro_transaccion=_nro_transac_cli  AND pago_aplicado ='S';

		UPDATE recaudo.pagos_xreversar SET pago_reversado ='S'
		WHERE nro_transaccion=_nro_transac_cli;


		RETURN retorno;
	ELSE
		RETURN 'ERR';
	END IF;


EXCEPTION WHEN OTHERS THEN
	INSERT INTO recaudo.pagos_xreversar(entidadrecaudadora,nro_transaccion,cod_motivo,creation_user )
	VALUES (_entidadrecaudadora,_nro_transac_cli,_cod_motivo,_usuario);

        RAISE NOTICE 'THE TRANSACTION IS IN AN UNCOMMITTABLE STATE.';

	RETURN retorno;
END;


$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION recaudo.sp_reversarpago_online(character varying, character varying, character varying, integer)
  OWNER TO postgres;
