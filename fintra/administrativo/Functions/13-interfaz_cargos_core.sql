-- Function: administrativo.interfaz_cargos_core()

-- DROP FUNCTION administrativo.interfaz_cargos_core();

CREATE OR REPLACE FUNCTION administrativo.interfaz_cargos_core()
  RETURNS boolean AS
$BODY$

DECLARE

 /************************************************
  *DESCRIPCION: ESTA FUNCION BUSCA LOS EMPLEADOS CREADOS PARA TRASLADO A APOTEOSYS
  *AUTOR		:=		@DVALENCIA
  *FECHA CREACION	:=		2018-07-23

  ************************************************/

CARGOS_CORE RECORD;
DETALLE RECORD;
CTYPE ADMINISTRATIVO.TYPE_CARGOS;
SW TEXT:='N';
rs boolean :=FALSE;


BEGIN
	/**SACAMOS EL LISTADO DE EMPLEADOS*/
	FOR CARGOS_CORE IN
		SELECT
			CODIGO AS CARGO__CODIGO____B,
			DESCRIPCION AS CARGO__NOMBRE____B, PROCESADO_APOT
		FROM ADMINISTRATIVO.CARGOS
		WHERE PROCESADO_APOT = 'N'


	--SELECT ADMINISTRATIVO.INTERFAZ_CARGOS_CORE();

	LOOP


			CTYPE.CARGO__CODIGO____B:=CARGOS_CORE.CARGO__CODIGO____B;
			CTYPE.CARGO__NOMBRE____B:=CARGOS_CORE.CARGO__NOMBRE____B;
			CTYPE.CARGO__FECHORCRE_B:=NOW();
			CTYPE.CARGO__FEHOULMO__B:=NOW();
			CTYPE.cargo__autocrea__b:='COREFINTRA';
			CTYPE.cargo__autultmod_b:='COREFINTRA';



			SW:=ADMINISTRATIVO.CARGOS(CTYPE);



		RAISE NOTICE '<<<<==== TERMINO ====>>>> %',CARGOS_CORE.CARGO__NOMBRE____B;

		IF(SW = 'S')THEN
	 	       UPDATE  ADMINISTRATIVO.CARGOS  SET PROCESADO_APOT = 'S'
			WHERE CODIGO  = CARGOS_CORE.CARGO__CODIGO____B;
		END IF;
		rs :=TRUE;

	END LOOP;


RETURN  rs;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION administrativo.interfaz_cargos_core()
  OWNER TO postgres;
