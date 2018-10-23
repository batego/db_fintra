-- Function: con.interfaz_cuenta_diferidos_apoteosys(character varying, integer, character varying, character varying)

-- DROP FUNCTION con.interfaz_cuenta_diferidos_apoteosys(character varying, integer, character varying, character varying);

CREATE OR REPLACE FUNCTION con.interfaz_cuenta_diferidos_apoteosys(tipo_documento character varying, iteracion integer, agencia character varying, unidad_negocio character varying)
  RETURNS text AS
$BODY$

DECLARE

 /************************************************
  *DESCRIPCION: DEVUELVE LA CUENTA PARA EL ASIENTO SEGUN CORRESPONDA
  *AUTOR:=@MMEDINA
  *FECHA CREACION:=2017-07-25
  *LAST_UPDATE
  *DESCRIPCION DE CAMBIOS Y FECHA
  *PRODUCTIVO:=
  ************************************************/

CUENTAS_MI_ATL VARCHAR[] := '{27059801, I010130014169}';
CUENTAS_CA_ATL VARCHAR[] := '{27059802, 24080109, I010130014144}';
CUENTAS_CM_ATL VARCHAR[] := '{27059803, I010130014134}';
CUENTAS_MI_COR VARCHAR[] := '{27059811, I090130014169}';
CUENTAS_CA_COR VARCHAR[] := '{27059812, 24080117, I090130014144}';
CUENTAS_CM_COR VARCHAR[] := '{27059813, I090130014134}';
CUENTAS_FA VARCHAR[] := '{13050902, 27059602, 27050901, 22050904}';
CUENTAS_FB VARCHAR[] := '{13050521, 27050596, 27050591, 22050521}';
CUENTAS_FAI VARCHAR[] := '{13050902, 27059602, 27050901, 22050904, 13050902, 28150602}';--> AVAL INCLUIDO
CUENTAS_FBI VARCHAR[] := '{13050521, 27050596, 27050591, 22050521, 13050521, 28150520}';--> AVAL INCLUIDO
CUENTAS_FAIA VARCHAR[] := '{13050902, 27059602, 27050901, 22050904, 13050902, 28150602}';--> AVAL INCLUIDO
CUENTAS_FBIA VARCHAR[] := '{13050521, 27050596, 27050591, 22050521, 13050521, 28150520}';--> AVAL INCLUIDO
CUENTAS_LI VARCHAR[] := '{27050940,I010310014169}';
CUENTAS_FA_DIF_IF VARCHAR[] := '{27050901, I010150014180}';
CUENTAS_FA_DIF_CM VARCHAR[] := '{27059602, I010150014134}';
CUENTAS_FB_DIF_IF VARCHAR[] := '{27050591, I020150014180}';
CUENTAS_FB_DIF_CM VARCHAR[] := '{27050596, I020150014134}';
CUENTAS_FA_CONSUMO VARCHAR[] := '{13050902, 27050901, 27059602, 22050904, I010010014210}';
CUENTAS_FB_CONSUMO VARCHAR[] := '{13050521, 27050591, 27050596, 22050521, I010010014210}';
CUENTAS_FA_CONSUMO_IF VARCHAR[] := '{27050901, I010170014180}';
CUENTAS_FA_CONSUMO_CM VARCHAR[] := '{27059602, I010170014134}';
CUENTAS_FB_CONSUMO_IF VARCHAR[] := '{27050591, I020170014169}';
CUENTAS_FB_CONSUMO_CM VARCHAR[] := '{27050596, I020170014134}';
CUENTAS_FA_AUTOMOTOR VARCHAR[] := '{13050902,27050901,I010150014134,22050904}';
CUENTAS_FA_AUTOMOTOR_IF VARCHAR[] := '{27050901,I010140014180}';
CUENTAS_FA_AUTOMOTOR_CM VARCHAR[] := '{27059602,I010150014134}';
CUENTA_ASIENTO varchar := '';

BEGIN
	IF(agencia = 'ATL')THEN
		--> Microcredito Atlantico
		IF(tipo_documento = 'MI' and unidad_negocio = '1')THEN
			CUENTA_ASIENTO := CUENTAS_MI_ATL[iteracion];

		elsif (tipo_documento = 'CA' and unidad_negocio = '1')then
			CUENTA_ASIENTO := CUENTAS_CA_ATL[iteracion];

		elsif (tipo_documento = 'CM' and unidad_negocio = '1')then
			CUENTA_ASIENTO := CUENTAS_CM_ATL[iteracion];

		--> Educativo Atlantico
		elsif(tipo_documento = 'FA' and unidad_negocio = '12')then
			CUENTA_ASIENTO := CUENTAS_FA[iteracion];

		elsif (tipo_documento = 'FAI' and unidad_negocio = '12')then
			CUENTA_ASIENTO := CUENTAS_FAI[iteracion];

		elsif (tipo_documento = 'IF' and unidad_negocio = '12')then
			CUENTA_ASIENTO := 'E-'||CUENTAS_FA_DIF_IF[iteracion];

		elsif (tipo_documento = 'CM' and unidad_negocio = '12')then
			CUENTA_ASIENTO := 'E-'||CUENTAS_FA_DIF_CM[iteracion];

		--> Libranza
		elsif (tipo_documento = 'LI' and unidad_negocio = '22')then
			CUENTA_ASIENTO := CUENTAS_LI[iteracion];

		--> Consumo Atlantico
		elsif(tipo_documento = 'FA' and unidad_negocio = '14')then
			CUENTA_ASIENTO := CUENTAS_FA_CONSUMO[iteracion];

		elsif(tipo_documento = 'IF' and unidad_negocio = '14')then
			CUENTA_ASIENTO := 'C-'||CUENTAS_FA_CONSUMO_IF[iteracion];

		elsif(tipo_documento = 'CM' and unidad_negocio = '14')then
			CUENTA_ASIENTO := 'C-'||CUENTAS_FA_CONSUMO_CM[iteracion];

		elsif (tipo_documento = 'FAIA' and unidad_negocio = '14')then
			CUENTA_ASIENTO := CUENTAS_FAIA[iteracion];

		--> Automotor Atlantico
		elsif (tipo_documento = 'FA' and unidad_negocio = '13')then
			CUENTA_ASIENTO := CUENTAS_FA_AUTOMOTOR[iteracion];

		elsif (tipo_documento = 'IF' and unidad_negocio = '13')then
			CUENTA_ASIENTO := 'A-'||CUENTAS_FA_AUTOMOTOR_IF[iteracion];

		elsif (tipo_documento = 'CM' and unidad_negocio = '13')then
			CUENTA_ASIENTO := 'A-'||CUENTAS_FA_AUTOMOTOR_CM[iteracion];
		END IF;

	ELSIF (agencia  IN ('COR','SUC'))THEN
		--> Microcredito Cordoba Y Sucre
		IF(tipo_documento = 'MI' and unidad_negocio = '1')THEN
			CUENTA_ASIENTO := CUENTAS_MI_COR[iteracion];

		elsif (tipo_documento = 'CA' and unidad_negocio = '1')then
			CUENTA_ASIENTO := CUENTAS_CA_COR[iteracion];

		elsif (tipo_documento = 'CM' and unidad_negocio = '1')then
			CUENTA_ASIENTO := CUENTAS_CM_COR[iteracion];
		END IF;
	ELSIF (agencia = 'BOL')THEN
		-->Educativo Bolivar
		IF(tipo_documento = 'FB' and unidad_negocio = '12')THEN
			CUENTA_ASIENTO := CUENTAS_FB[iteracion];

		elsif (tipo_documento = 'FBI' and unidad_negocio = '12')then
			CUENTA_ASIENTO := CUENTAS_FBI[iteracion];

		elsif (tipo_documento = 'IF' and unidad_negocio = '12')then
			CUENTA_ASIENTO := 'E-'||CUENTAS_FB_DIF_IF[iteracion];

		elsif (tipo_documento = 'CM' and unidad_negocio = '12')then
			CUENTA_ASIENTO := 'E-'||CUENTAS_FB_DIF_CM[iteracion];

		--> Consumo Bolivar
		elsif(tipo_documento = 'FB' and unidad_negocio = '14')then
			CUENTA_ASIENTO := CUENTAS_FB_CONSUMO[iteracion];

		elsif(tipo_documento = 'IF' and unidad_negocio = '14')then
			CUENTA_ASIENTO := 'C-'||CUENTAS_FB_CONSUMO_IF[iteracion];

		elsif(tipo_documento = 'CM' and unidad_negocio = '14')then
			CUENTA_ASIENTO := 'C-'||CUENTAS_FB_CONSUMO_CM[iteracion];

		elsif (tipo_documento = 'FBIA' and unidad_negocio = '14')then
			CUENTA_ASIENTO := CUENTAS_FBIA[iteracion];
		END IF;
	END IF;



	--raise notice 'CUENTA_ASIENTO %',CUENTA_ASIENTO;
RETURN CUENTA_ASIENTO;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_cuenta_diferidos_apoteosys(character varying, integer, character varying, character varying)
  OWNER TO postgres;
