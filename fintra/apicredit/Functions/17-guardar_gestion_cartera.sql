-- Function: apicredit.guardar_gestion_cartera(integer, character varying, character varying, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying)

-- DROP FUNCTION apicredit.guardar_gestion_cartera(integer, character varying, character varying, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION apicredit.guardar_gestion_cartera(_tipogestion integer, _negocio character varying, _observacion character varying, _valorpago numeric, _fechapago character varying, _ciudad character varying, _barrio character varying, _direccion character varying, _fecha_prox_gestion character varying, _prox_accion character varying, _estado_cliente character varying, _user character varying)
  RETURNS text AS
$BODY$

DECLARE

  rs varchar:='OK';
  retcod record;

BEGIN

	/***Guardar Gestion***/
	--si la opcion es 19 (Compromiso de pago)
	IF(_tipoGestion=19)THEN

		INSERT INTO con.compromiso_pago_cartera(
			dstrct, negocio, observacion, valor_a_pagar, fecha_a_pagar,
			ciudad, barrio, direccion, creation_date, creation_user)
		VALUES ('FINV', UPPER(_negocio), _observacion, _valorPago, _fechaPago::date,
			_ciudad, _barrio, _direccion, NOW(), _user);

	ELSE
		--si es diferente de 19

		FOR retcod IN ( SELECT documento,valor_saldo,codcli
					FROM con.factura f
				WHERE f.reg_status = ''
				 and f.dstrct = 'FINV'
				 and f.tipo_documento in ('FAC','NDC')
				 and f.valor_saldo > 0
				 and replace(substring(f.fecha_vencimiento,1,7),'-','')::numeric <= replace(substring(now(),1,7),'-','')::numeric
				 and f.negasoc = _negocio)
		LOOP

			INSERT INTO con.factura_observacion(
				dstrct, documento, observacion, last_update,
				user_update, creation_date, creation_user, base,
				tipo_gestion, fecha_prox_gestion, prox_accion, tipo, dato)
			VALUES ('FINV', retcod.documento,UPPER(_observacion), '0099-01-01 00:00:00', '', NOW(), _user, 'COL',
				_tipoGestion::text, _fecha_prox_gestion::timestamp without time zone, _prox_accion::text,'','');


			UPDATE con.factura
			SET obs='1'
			WHERE documento=retcod.documento AND reg_status='';

			UPDATE cliente SET estado_gestion_cartera=_estado_cliente WHERE codcli=retcod.codcli;

		END LOOP;

	END IF;

	RETURN rs;



END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION apicredit.guardar_gestion_cartera(integer, character varying, character varying, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying)
  OWNER TO postgres;
