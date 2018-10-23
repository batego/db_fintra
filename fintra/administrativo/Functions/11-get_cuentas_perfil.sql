-- Function: administrativo.get_cuentas_perfil(character varying, integer)

-- DROP FUNCTION administrativo.get_cuentas_perfil(character varying, integer);

CREATE OR REPLACE FUNCTION administrativo.get_cuentas_perfil(perfil character varying, _idconvenio integer)
  RETURNS character varying[] AS
$BODY$
DECLARE

rs boolean :=false;
arrayCuentaPerfil varchar[];
_convenioRecord record ;

BEGIN

	SELECT INTO _convenioRecord * FROM convenios WHERE  id_convenio=_idconvenio AND agencia !='';
	--OBTENEMOS LAS CUENTAS DEPENDIENDO EL PERFIL CONTABLE--

	/******************************************************
	* Bloque de cuentas para generacion de documentos proceso de FIANZA MICRO *
	******************************************************/
        IF(_convenioRecord.prefijo_negocio ='NEG_MICROCRED')THEN

		--VALIDAMOS LAS AGENCIAS
		--ATLANTICO
		IF(_convenioRecord.agencia='ATL')THEN

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
				arrayCuentaPerfil[2] := '11050528'; --CUENTA DETALLE IC FIANZA CARTERA INDEMNIZADA
			END IF;

			IF (perfil='CXC_FIANZA') THEN
				arrayCuentaPerfil[1] := '13809510'; --CUENTA HC O CMC IC FIANZA INDEMNIZACION
				arrayCuentaPerfil[2] := '11050528'; --CUENTA DETALLE CXC FIANZA INDEMNIZACION
			END IF;

		END IF;

		--CORDOBA
		IF(_convenioRecord.agencia in ('COR','SUC'))THEN

			IF (perfil='CXP_FIANZA_TEMP') THEN
				arrayCuentaPerfil[1] := '28150709'; --CUENTA HC O CMC CXP FIANZA TEMPORAL FAP
				arrayCuentaPerfil[2] := '23051105'; --CUENTA DETALLE CXP FIANZA TEMPORAL
			END IF;

			IF (perfil='NC_FIANZA_TEMP') THEN
				arrayCuentaPerfil[1] := '28150709'; --CUENTA HC O CMC NOTA CREDITO FIANZA TEMPORAL NC
				arrayCuentaPerfil[2] := '11050526'; --CUENTA DETALLE NOTA CREDITO FIANZA TEMPORAL
			END IF;

			IF (perfil='CXP_FIANZA_DEF') THEN
				arrayCuentaPerfil[1] := '28150711'; --CUENTA HC O CMC CXP FIANZA DEFINITIVA FAP
				arrayCuentaPerfil[2] := '11050526'; --CUENTA DETALLE CXP FIANZA DEFINITIVA
			END IF;

			IF (perfil='IC_FIANZA_INDEM') THEN
				arrayCuentaPerfil[1] := '13050806'; --CUENTA HC O CMC IC FIANZA CARTERA INDEMNIZADA
				arrayCuentaPerfil[2] := '11050528'; --CUENTA DETALLE IC FIANZA CARTERA INDEMNIZADA
			END IF;

			IF (perfil='CXC_FIANZA') THEN
				arrayCuentaPerfil[1] := '13809511'; --CUENTA HC O CMC IC FIANZA INDEMNIZACION
				arrayCuentaPerfil[2] := '11050528'; --CUENTA DETALLE CXC FIANZA INDEMNIZACION
			END IF;

		END IF;


	END IF; --fin bloque:  Documentos proceso de FIANZA MICRO


        /****************************************************************************
	* Bloque de cuentas para generacion de documentos proceso de FIANZA LIBRANZA *
	******************************************************************************/

	IF(_convenioRecord.prefijo_negocio ='NEG_LIBRANZA')THEN

		--ATLANTICO
		IF(_convenioRecord.agencia ='ATL')THEN

			IF (perfil='CXP_FIANZA_LBT') THEN
				arrayCuentaPerfil[1] := '28150909'; --CUENTA HC O CMC CXP FIANZA TEMPORAL FAP
				arrayCuentaPerfil[2] := '23050940'; --CUENTA DETALLE CXP FIANZA TEMPORAL
			END IF;

			IF (perfil='NC_FIANZA_LBT') THEN
				arrayCuentaPerfil[1] := '28150909'; --CUENTA HC O CMC NOTA CREDITO FIANZA TEMPORAL NC
				arrayCuentaPerfil[2] := '11050526'; --CUENTA DETALLE NOTA CREDITO FIANZA TEMPORAL
			END IF;

			IF (perfil='CXP_FIANZA_LBD') THEN
				arrayCuentaPerfil[1] := '28150910'; --CUENTA HC O CMC CXP FIANZA DEFINITIVA FAP
				arrayCuentaPerfil[2] := '11050526'; --CUENTA DETALLE CXP FIANZA DEFINITIVA
			END IF;

			IF (perfil='IC_FIANZA_INDEM_LB') THEN
				arrayCuentaPerfil[1] := '13050941'; --CUENTA HC O CMC IC FIANZA CARTERA INDEMNIZADA
				arrayCuentaPerfil[2] := '11050529'; --CUENTA DETALLE IC FIANZA CARTERA INDEMNIZADA
			END IF;

			IF (perfil='CXC_FIANZA_LB') THEN
				arrayCuentaPerfil[1] := '13809512'; --CUENTA HC O CMC IC FIANZA INDEMNIZACION
				arrayCuentaPerfil[2] := '11050529'; --CUENTA DETALLE CXC FIANZA INDEMNIZACION
			END IF;


		END IF;

	END IF;  --fin bloque:  Documentos proceso de FIANZA LIBRANZA


       raise notice 'arrayCuentaPerfil %',arrayCuentaPerfil;

       RETURN arrayCuentaPerfil;

END $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION administrativo.get_cuentas_perfil(character varying, integer)
  OWNER TO postgres;
