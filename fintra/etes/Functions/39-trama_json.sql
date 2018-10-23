-- Function: etes.trama_json(text[], character varying, character varying, character varying)

-- DROP FUNCTION etes.trama_json(text[], character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION etes.trama_json(anticipo text[], tramajson character varying, tipotrama character varying, usuario character varying)
  RETURNS integer AS
$BODY$
DECLARE

id_tabla integer:=0;

BEGIN

        /****************************************************************************************/
	/*************************   GUARDAMOS LA TRAMA PARA LLEVAR HISTORICO  ******************/
	/****************************************************************************************/
	RAISE NOTICE 'COD_EMPRESA : %',anticipo[1][1];
		INSERT INTO etes.trama_anticipos(
			    json, id_empresa, procesado,tipo_trama, fecha_inicio_proceso,
			    creation_user, creation_date)
		    VALUES (tramajson,(SELECT id FROM etes.transportadoras  WHERE cod_transportadora=anticipo[1][1]), false,tipoTrama, now(),
			    usuario, now())
			    RETURNING id INTO id_tabla ;

return id_tabla;

EXCEPTION

	WHEN foreign_key_violation THEN
		RAISE EXCEPTION 'NO EXISTEN DEPENDENCIAS FORANEAS PARA ALGUNOS REGISTROS.';
	WHEN unique_violation THEN
		RAISE EXCEPTION'ERROR INSERTANDO EN LA BD, YA EXISTE EL PROCESO EN LA BASE DE DATOS.';
        WHEN  null_value_not_allowed  THEN
		RAISE EXCEPTION 'VALOR NULO NO PERMITIDO';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.trama_json(text[], character varying, character varying, character varying)
  OWNER TO postgres;
