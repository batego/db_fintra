-- Function: etes.get_cuentas_perfil(character varying)

-- DROP FUNCTION etes.get_cuentas_perfil(character varying);

CREATE OR REPLACE FUNCTION etes.get_cuentas_perfil(perfil character varying)
  RETURNS character varying[] AS
$BODY$
DECLARE

rs boolean :=false;
arrayCuentaPerfil varchar[];

BEGIN

	--OBTENEMOS LAS CUENTAS DEPENDIENDO EL PERFIL CONTABLE--

	/*********************************************************
	* Bloque de cuentas para para generacion de corridas CXC *
	**********************************************************/

        IF (perfil='IA_TRANSPORTADORA') THEN
		arrayCuentaPerfil[1] := '13802805'; --CUENTA CABECERA IA TRANSPORTADORA
		arrayCuentaPerfil[2] := '13802804'; --CUANTA DETALLE CMC CXC HAROLD FAC
	END IF;

	IF (perfil='CXC_TRANSPORTADORA') THEN
		arrayCuentaPerfil[1] := '13802806'; --CUENTA DEL HC PARA BUSCAR EN CMC FAC
		arrayCuentaPerfil[2] := '13802805'; --CUENTA DETALLE CXC TRANSPORTADORA
	END IF;


	/*************************
	* fin bloque: corridas   *
	**************************/

	/******************************************************
	* Bloque de cuentas para para generacion de CXP EDS  *
	******************************************************/

	IF (perfil='CXP_EDS') THEN
		arrayCuentaPerfil[1] := '22050413'; --CUENTA HC O CMC CXP EDS FAP
		arrayCuentaPerfil[2] := '23050313'; --CUENTA DETALLE CXP EDS
	END IF;

	/*************************
	* fin bloque: CXP EDS    *
	**************************/

	/***********************************************************
	* Bloque de cuentas para para egreso modulo transferencia  *
	***********************************************************/

	IF (perfil='EGRESO_TRANSFERENCIA') THEN
		arrayCuentaPerfil[1] := '22050407'; --ITEM 1 DEL EGRESO CUETA A CXP
		arrayCuentaPerfil[2] := 'I010290024208'; --COMISION BANCARIA

	END IF;

	/************************************
	* fin bloque: EGRESO  TRANSFERENCIA *
	*************************************/

	/*************************************************
	* Bloque de cuentas para cxp de la transferencia  *
	***************************************************/

	IF (perfil='CXP_TRANSFERENCIA') THEN
		arrayCuentaPerfil[1] := '22050407'; --HC: IC | 22050407
		arrayCuentaPerfil[2] := '23050307'; --Detalle: 23050307
	END IF;

	/************************************
	* fin bloque: fin cxp transferencia *
	*************************************/

	/********************************************************************
	* Bloque de cuentas para contabilizacion nacimiento etes transaccion*
	*********************************************************************/

	IF (perfil='AET_TRANSFERENCIA') THEN
		arrayCuentaPerfil[1] := '13802802'; --FAC
		arrayCuentaPerfil[2] := 'I010290024153'; --FAC
		arrayCuentaPerfil[3] := '22050407'; --FAP
	END IF;

	/************************************
	* fin bloque: fin AET_TRANSFERENCIA *
	*************************************/

	/********************************************************************
	* Bloque de cuentas para contabilizacion corrida*
	*********************************************************************/

	IF (perfil='CORRIDA_TRANSFERENCIA') THEN
		arrayCuentaPerfil[1] := '13802806'; --FAC
		arrayCuentaPerfil[2] := '13802802'; --FAC
	END IF;

	/************************************
	* fin bloque: fin AET_TRANSFERENCIA *
	*************************************/


       raise notice 'arrayCuentaPerfil %',arrayCuentaPerfil;

       RETURN arrayCuentaPerfil;

END $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.get_cuentas_perfil(character varying)
  OWNER TO postgres;
