-- Function: opav.sl_validacion_cuentas(character varying)

-- DROP FUNCTION opav.sl_validacion_cuentas(character varying);

CREATE OR REPLACE FUNCTION opav.sl_validacion_cuentas(perfil character varying)
  RETURNS boolean AS
$BODY$
DECLARE

rs boolean :=false;
arrayCuentaPerfil varchar[];


BEGIN


	--OBTENEMOS LAS CUENTAS DEPENDIENDO EL PERFIL CONTABLE--

	/******************************************************
	* Bloque de cuentas para para generacion de CXP ASEGURADORA  *
	******************************************************/

	IF (perfil='CXP_ASEGURADORA') THEN
		arrayCuentaPerfil[1] := '23355502'; --CUENTA HC O CMC CXP ASEGURADORA FAP
		arrayCuentaPerfil[2] := 'G010120065149'; --CUENTA DETALLE CXP ASEGURADORA
	END IF;

	/*************************
	* fin bloque: CXP ASEGURADORA *
	**************************/

	--VALIDAMOS LAS CUENTAS--
	FOR i IN 1 .. (array_upper(arrayCuentaPerfil, 1))LOOP
                RAISE NOTICE 'arrayCuentaPerfil[i]: %',arrayCuentaPerfil[i];
		rs:= EXISTS(SELECT * FROM con.cuentas  where cuenta=arrayCuentaPerfil[i]) ;
		EXIT WHEN rs IS NOT TRUE;
	END LOOP;



  RETURN rs;

END $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sl_validacion_cuentas(character varying)
  OWNER TO postgres;
