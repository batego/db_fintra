-- Function: eg_migrar_imagenes(integer)

-- DROP FUNCTION eg_migrar_imagenes(integer);

CREATE OR REPLACE FUNCTION eg_migrar_imagenes(i integer)
  RETURNS text AS
$BODY$
DECLARE
  mensaje text:='OK';

BEGIN
	/* esto es una prueba */
	PERFORM dblink_connect('conexion','dbname=fintra port=5432 host=190.7.139.58 user=postgres password=h4r0ldcu..');
	IF FOUND THEN
		INSERT INTO archivos_multiservicios (
		-- QUERY A OTRA BASE DE DATOS
		SELECT a.reg_status,a.dstrct,a.document,a.filename,a.filebinary,a.agencia,a.last_update,a.user_update,a.creation_date,a.creation_user,a.tipo
		FROM dblink('conexion', 'SELECT reg_status,dstrct,document,filename,filebinary,agencia,last_update,user_update,creation_date,creation_user,tipo FROM archivos_multiservicios limit 300  offset '||i )
		AS a (
		 -- id integer,
		  reg_status character varying,
		  dstrct character varying,
		  document character varying,
		  filename character varying,
		  filebinary bytea,
		  agencia character varying,
		  last_update timestamp without time zone,
		  user_update character varying,
		  creation_date timestamp without time zone,
		  creation_user character varying,
		  tipo character varying
		)
		);


		-- DESCONECTAR
		PERFORM dblink_disconnect('conexion');
		IF NOT FOUND THEN

		   mensaje:='ERROR AL DESCONECTAR EL DBLINK';
		   RETURN mensaje;

		END IF;

		 RETURN mensaje;

	ELSE
	    mensaje:='NO SE CONECTO EL DBLINK';
	    RETURN mensaje;
	END IF;



END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_migrar_imagenes(integer)
  OWNER TO postgres;
