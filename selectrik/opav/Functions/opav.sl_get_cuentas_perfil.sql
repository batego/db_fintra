-- Function: opav.sl_get_cuentas_perfil(character varying)

-- DROP FUNCTION opav.sl_get_cuentas_perfil(character varying);

CREATE OR REPLACE FUNCTION opav.sl_get_cuentas_perfil(perfil character varying)
  RETURNS character varying[] AS
$BODY$
DECLARE

rs boolean :=false;
arrayCuentaPerfil varchar[];

BEGIN

	--OBTENEMOS LAS CUENTAS DEPENDIENDO EL PERFIL CONTABLE--

	/******************************************************
	* Bloque de cuentas para generacion de CXP ASEGURADORA *
	******************************************************/

	IF (perfil='CXP_ASEGURADORA') THEN
		arrayCuentaPerfil[1] := '23355502'; --CUENTA HC O CMC CXP ASEGURADORA FAP
		arrayCuentaPerfil[2] := 'G010120065149'; --CUENTA DETALLE CXP ASEGURADORA
	END IF;

	/*************************
	* fin bloque: CXP ASEGURADORA  *
	**************************/

       raise notice 'arrayCuentaPerfil %',arrayCuentaPerfil;

       RETURN arrayCuentaPerfil;

END $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.sl_get_cuentas_perfil(character varying)
  OWNER TO postgres;
