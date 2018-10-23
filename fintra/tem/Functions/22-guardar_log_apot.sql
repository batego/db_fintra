-- Function: tem.guardar_log_apot(integer, character varying, character varying, character varying, character varying, integer)

-- DROP FUNCTION tem.guardar_log_apot(integer, character varying, character varying, character varying, character varying, integer);

CREATE OR REPLACE FUNCTION tem.guardar_log_apot(_operacion integer, _dstrct character varying, _linea_negocio character varying, _spnombre character varying, _spresultado character varying, _idproceso integer)
  RETURNS integer AS
$BODY$
DECLARE

_id integer:=0;

BEGIN

	IF(_operacion = 1)THEN

		INSERT INTO tem.log_proceso_contabilizacion_apot(
				    dstrct, linea_negocio, fecha_inicio,
				    sp_nombre, creation_date,creation_user)
			    VALUES (_dstrct, _linea_negocio, now(),
				    _spnombre,now(),'CRONTAB')RETURNING id INTO _id;

	ELSE
		UPDATE tem.log_proceso_contabilizacion_apot
			SET fecha_fin=NOW() , sp_resultado=_spresultado
		WHERE id=_idproceso;

	END IF;


	RETURN _id;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION tem.guardar_log_apot(integer, character varying, character varying, character varying, character varying, integer)
  OWNER TO postgres;
