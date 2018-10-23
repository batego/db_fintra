-- Function: con.interfaz_fintra_logistica_apoteosys_c_diarios()

-- DROP FUNCTION con.interfaz_fintra_logistica_apoteosys_c_diarios();

CREATE OR REPLACE FUNCTION con.interfaz_fintra_logistica_apoteosys_c_diarios()
  RETURNS text AS
$BODY$

DECLARE

 /************************************************
  *DESCRIPCION: ESTA FUNCION TOMA LOS COMPROBANTES DIARIOS DE ANTICIPOS ANULADOS Y
  *CONTRUYE EL ASIENTO CONTABLE QUE MAS ADELANTE SE TRASLADARA A APOTEOSYS.
  *DOCUMENTACION:=
  *AUTOR:=@JZAPATA
  *FECHA CREACION:=2017-12-01
  *LAST_UPDATE
  *DESCRIPCION DE CAMBIOS Y FECHA
  ************************************************/


 REC_OS RECORD;
 SECUENCIA_EXT INTEGER;
 CONSEC INTEGER:=1;
 FECHADOC_ TEXT:='';
 SW TEXT:='N';
 MCTYPE CON.TYPE_INSERT_MC;

 BEGIN


 	RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_fintra_logistica_apoteosys_c_diarios()
  OWNER TO postgres;
