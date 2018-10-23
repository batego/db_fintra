-- Function: con.interfaz_cuenta_cuotadmin_apoteosys(character varying, integer, character varying, character varying)

-- DROP FUNCTION con.interfaz_cuenta_cuotadmin_apoteosys(character varying, integer, character varying, character varying);

CREATE OR REPLACE FUNCTION con.interfaz_cuenta_cuotadmin_apoteosys(tipo_documento character varying, iteracion integer, agencia character varying, unidad_negocio character varying)
  RETURNS text AS
$BODY$

DECLARE

 /************************************************
  *DESCRIPCION: DEVUELVE LA CUENTA PARA EL ASIENTO SEGUN CORRESPONDA
  *AUTOR:=@MMEDINA
  *FECHA CREACION:=2017-08-18
  *LAST_UPDATE
  *DESCRIPCION DE CAMBIOS Y FECHA
  *PRODUCTIVO:=
  ************************************************/

CUENTAS_CM_FA_EDC VARCHAR[] := '{13050902,I010150014134}';
CUENTAS_CM_FB_EDU VARCHAR[] := '{13050521,I020150014134}';
CUENTAS_CM_FA_CON VARCHAR[] := '{13050902,I010170014134}';
CUENTAS_CM_FB_CON VARCHAR[] := '{13050521,I020170014134}';

CUENTA_ASIENTO varchar := '';

BEGIN
	IF(agencia = 'ATL')THEN
		--> Educativo Atlantico
		if(tipo_documento = 'CMFA' and unidad_negocio = '12')then
			CUENTA_ASIENTO := CUENTAS_CM_FA_EDC[iteracion];
		elsif(tipo_documento = 'CMFA' and unidad_negocio = '14')then
			CUENTA_ASIENTO := CUENTAS_CM_FA_CON[iteracion];
		END IF;

	ELSIF (agencia = 'BOL')THEN
		-->Educativo Bolivar
		IF(tipo_documento = 'CMFB' and unidad_negocio = '12')THEN
			CUENTA_ASIENTO := CUENTAS_CM_FB_EDU[iteracion];

		elsif (tipo_documento = 'CMFB' and unidad_negocio = '14')then
			CUENTA_ASIENTO := CUENTAS_CM_FB_CON[iteracion];
		END IF;
	END IF;



	--raise notice 'CUENTA_ASIENTO %',CUENTA_ASIENTO;
RETURN CUENTA_ASIENTO;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_cuenta_cuotadmin_apoteosys(character varying, integer, character varying, character varying)
  OWNER TO postgres;
