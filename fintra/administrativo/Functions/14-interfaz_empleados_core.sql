-- Function: administrativo.interfaz_empleados_core()

-- DROP FUNCTION administrativo.interfaz_empleados_core();

CREATE OR REPLACE FUNCTION ADMINISTRATIVO.INTERFAZ_EMPLEADOS_CORE()
  RETURNS boolean AS
$BODY$

DECLARE

 /************************************************
  *DESCRIPCION: ESTA FUNCION BUSCA LOS EMPLEADOS CREADOS PARA TRASLADO A APOTEOSYS
  *AUTOR		:=		@DVALENCIA	
  *FECHA CREACION	:=		2018-07-23
  
  ************************************************/

EMPLEADOS_CORE RECORD;
DETALLE RECORD;
MCTYPE ADMINISTRATIVO.TYPE_EMPLEADOS;
SW TEXT:='N';
rs boolean :=FALSE;

BEGIN
	/**SACAMOS EL LISTADO DE EMPLEADOS*/
	FOR EMPLEADOS_CORE IN 
		SELECT IDENTIFICACION AS FUNCIO_IDENTIFIC_B, 
		       'CC' AS FUNCIO_CODIGO____TIT____B,
		       SPLIT_PART(NOMBRE_COMPLETO,' ',3) ||' '|| SPLIT_PART(NOMBRE_COMPLETO,' ',4) AS FUNCIO_NOMBCORT__B,
		       SPLIT_PART(NOMBRE_COMPLETO,' ',1) ||' '|| SPLIT_PART(NOMBRE_COMPLETO,' ',2) AS FUNCIO_APELLIDOS_B, 
		       NOMBRE_COMPLETO AS FUNCIO_NOMBEXTE__B,  
		       'RSEN' AS FUNCIO_CODIGO____TT_____B,
		       E.DIRECCION AS FUNCIO_DIRECCION_B,
		       CA.CIUDAD_CODIGO____B AS FUNCIO_CODIGO____CIUDAD_B,
		       E.TELEFONO AS FUNCIO_TELEFONO1_B,              
		       C.CODIGO AS FUNCIO_CODIGO____CARGO__B,
		       IDUSUARIO AS FUNCIO_CODIGO____USUARI_B,
		       CASE WHEN E.EMAIL ='0' THEN 'PENDIENTE' ELSE E.EMAIL END AS FUNCIO_EMAIL_____B
		FROM ADMINISTRATIVO.EMPLEADOS E
		INNER JOIN CIUDAD CI ON CI.CODCIU = E.CIUDAD
		INNER JOIN TEM.CIUDADES_APOTEOSYS CA ON CA.CIUDAD_NOMBRE____B=UPPER(CI.NOMCIU)
		INNER JOIN ADMINISTRATIVO.CARGOS C ON C.ID=E.ID_CARGO
		LEFT JOIN USUARIOS U ON U.NIT=E.IDENTIFICACION
		WHERE E.PROCESADO_APOT = 'N' AND E.REG_STATUS = '' --AND U.ESTADO = 'A'
		ORDER BY FUNCIO_IDENTIFIC_B
		
	--SELECT ADMINISTRATIVO.INTERFAZ_EMPLEADOS_CORE() AS RETORNO;

	LOOP

			MCTYPE.FUNCIO_IDENTIFIC_B:= EMPLEADOS_CORE.FUNCIO_IDENTIFIC_B;
			MCTYPE.FUNCIO_CODIGO____TIT____B:= EMPLEADOS_CORE.FUNCIO_CODIGO____TIT____B;
			MCTYPE.FUNCIO_NOMBCORT__B:= EMPLEADOS_CORE.FUNCIO_NOMBCORT__B;
			MCTYPE.FUNCIO_APELLIDOS_B:= EMPLEADOS_CORE.FUNCIO_APELLIDOS_B;
			MCTYPE.FUNCIO_NOMBEXTE__B:= EMPLEADOS_CORE.FUNCIO_NOMBEXTE__B;
			MCTYPE.FUNCIO_CODIGO____TT_____B:= EMPLEADOS_CORE.FUNCIO_CODIGO____TT_____B;
			MCTYPE.FUNCIO_DIRECCION_B:= EMPLEADOS_CORE.FUNCIO_DIRECCION_B;
			MCTYPE.FUNCIO_CODIGO____CIUDAD_B:= EMPLEADOS_CORE.FUNCIO_CODIGO____CIUDAD_B;
			MCTYPE.FUNCIO_TELEFONO1_B:= EMPLEADOS_CORE.FUNCIO_TELEFONO1_B;             
			MCTYPE.FUNCIO_CODIGO____CARGO__B:= EMPLEADOS_CORE.FUNCIO_CODIGO____CARGO__B;
			MCTYPE.FUNCIO_CODIGO____USUARI_B:= EMPLEADOS_CORE.FUNCIO_CODIGO____USUARI_B;
			MCTYPE.FUNCIO_EMAIL_____B:= EMPLEADOS_CORE.FUNCIO_EMAIL_____B;
			MCTYPE.FUNCIO_FECHORCRE_B:=NOW();
			MCTYPE.FUNCIO_FEHOULMO__B:=NOW();
			MCTYPE.FUNCIO_AUTOCREA__B:='COREFINTRA';
			MCTYPE.FUNCIO_AUTULTMOD_B:='COREFINTRA';


		 			
			
			SW:=ADMINISTRATIVO.FUNCIO_APOT(MCTYPE);
		
		RAISE NOTICE '<<<<==== TERMINO ====>>>> %',EMPLEADOS_CORE.FUNCIO_IDENTIFIC_B;

		IF(SW = 'S')THEN
	 	       UPDATE  ADMINISTRATIVO.EMPLEADOS  SET PROCESADO_APOT = 'S' 
			WHERE IDENTIFICACION  = EMPLEADOS_CORE.FUNCIO_IDENTIFIC_B;
		END IF;
		rs :=TRUE;
		
	END LOOP;

	
RETURN  rs;
	
END;
$BODY$
  LANGUAGE PLPGSQL VOLATILE;
ALTER FUNCTION ADMINISTRATIVO.INTERFAZ_EMPLEADOS_CORE()
  OWNER TO POSTGRES;