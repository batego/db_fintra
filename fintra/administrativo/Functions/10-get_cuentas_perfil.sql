-- Function: administrativo.get_cuentas_perfil(character varying)

-- DROP FUNCTION administrativo.get_cuentas_perfil(character varying);

CREATE OR REPLACE FUNCTION administrativo.get_cuentas_perfil(perfil character varying)
  RETURNS character varying[] AS
$BODY$
DECLARE

rs boolean :=false;
arrayCuentaPerfil varchar[];

BEGIN

	--OBTENEMOS LAS CUENTAS DEPENDIENDO EL PERFIL CONTABLE--

	/******************************************************
	* Bloque de cuentas para generacion de documentos proceso de FIANZA MICRO *
	******************************************************/

	IF (perfil='CXP_FIANZA_TEMP') THEN
		arrayCuentaPerfil[1] := '28150704'; --CUENTA HC O CMC CXP FIANZA TEMPORAL FAP
		arrayCuentaPerfil[2] := '23051101'; --CUENTA DETALLE CXP FIANZA TEMPORAL
	END IF;

	IF (perfil='NC_FIANZA_TEMP') THEN
		arrayCuentaPerfil[1] := '28150704'; --CUENTA HC O CMC NOTA CREDITO FIANZA TEMPORAL NC
		arrayCuentaPerfil[2] := '11050526'; --CUENTA DETALLE NOTA CREDITO FIANZA TEMPORAL
	END IF;

	IF (perfil='CXP_FIANZA_DEF') THEN
		arrayCuentaPerfil[1] := '28150705'; --CUENTA HC O CMC CXP FIANZA DEFINITIVA FAP
		arrayCuentaPerfil[2] := '11050526'; --CUENTA DETALLE CXP FIANZA DEFINITIVA
	END IF;

	IF (perfil='IC_FIANZA_INDEM') THEN
		arrayCuentaPerfil[1] := '13050802'; --CUENTA HC O CMC IC FIANZA CARTERA INDEMNIZADA
		arrayCuentaPerfil[2] := '11050527'; --CUENTA DETALLE IC FIANZA CARTERA INDEMNIZADA
	END IF;

	IF (perfil='CXC_FIANZA') THEN
		arrayCuentaPerfil[1] := '13809510'; --CUENTA HC O CMC IC FIANZA INDEMNIZACION
		arrayCuentaPerfil[2] := '11050527'; --CUENTA DETALLE CXC FIANZA INDEMNIZACION
	END IF;

	/*************************
	* fin bloque:  Documentos proceso de FIANZA MICRO *
	**************************/

	 /******************************************************
	* Bloque de cuentas para generacion de documentos proceso de FIANZA LIBRANZA *
	******************************************************/

	IF (perfil='CXP_FIANZA_LBT') THEN
		arrayCuentaPerfil[1] := '28150909'; --CUENTA HC O CMC CXP FIANZA TEMPORAL FAP
		arrayCuentaPerfil[2] := '23050942'; --CUENTA DETALLE CXP FIANZA TEMPORAL
	END IF;

	IF (perfil='NC_FIANZA_LBT') THEN
		arrayCuentaPerfil[1] := '28150909'; --CUENTA HC O CMC NOTA CREDITO FIANZA TEMPORAL NC
		arrayCuentaPerfil[2] := '11050526'; --CUENTA DETALLE NOTA CREDITO FIANZA TEMPORAL
	END IF;

	IF (perfil='CXP_FIANZA_LBD') THEN
		arrayCuentaPerfil[1] := '28150910'; --CUENTA HC O CMC CXP FIANZA DEFINITIVA FAP
		arrayCuentaPerfil[2] := '11050526'; --CUENTA DETALLE CXP FIANZA DEFINITIVA
	END IF;

	/*************************
	* fin bloque:  Documentos proceso de FIANZA LIBRANZA  *
	**************************/
       raise notice 'arrayCuentaPerfil %',arrayCuentaPerfil;

       RETURN arrayCuentaPerfil;

END $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION administrativo.get_cuentas_perfil(character varying)
  OWNER TO postgres;
