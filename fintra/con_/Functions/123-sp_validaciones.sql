-- Function: con.sp_validaciones(con.type_insert_mc, character varying)

-- DROP FUNCTION con.sp_validaciones(con.type_insert_mc, character varying);

CREATE OR REPLACE FUNCTION con.sp_validaciones(mctype con.type_insert_mc, linea_negocio character varying)
  RETURNS text AS
$BODY$

DECLARE
  sw varchar:='S';

BEGIN

/*****************************************************
*VALIDACIONES ....				     *
*autor:@egonzalez				     *
*fecha: 2017-05-19				     *

*modificado:@mmedina
*fecha:2017-06-21
******************************************************/



	if (linea_negocio = 'LOGISTICA')then
		--1.)VALIDAMOS DEBITO Y CREDITO
	       IF (SELECT SUM(MC_____DEBMONLOC_B)-SUM(MC_____CREMONLOC_B)
			FROM  CON.MC____
			WHERE MC_____NUMERO____B =mctype.MC_____NUMERO____B
			      AND MC_____CODIGO____TD_____B=mctype.MC_____CODIGO____TD_____B
			      AND MC_____CODIGO____CD_____B=mctype.MC_____CODIGO____CD_____B ) !=0 THEN


			--1.) insertar en la tabla de log (log_carga_apoteosys)
			INSERT INTO CON.LOG_CARGA_APOTEOSYS(TIPO_DOC, CLASE_DOC, ORDEN_SERVICIO, MENSAJE_ERROR) VALUES(MCTYPE.MC_____CODIGO____TD_____B,
				MCTYPE.MC_____CODIGO____CD_____B,MCTYPE.MC_____NUMERO_OPER_B, 'ERROR, DEBITO Y CREDITO DESCUADRADOS.');

			--2.) borrar registros de la tabla CON.MC____
			DELETE FROM CON.MC____ WHERE MC_____NUMERO____B =mctype.MC_____NUMERO____B   AND MC_____CODIGO____TD_____B=mctype.MC_____CODIGO____TD_____B  AND
				MC_____CODIGO____CD_____B=mctype.MC_____CODIGO____CD_____B ;

			--3.) cambiar sw a n
			sw ='N';

		END IF;
	elsif (linea_negocio = 'MICROCREDITO')then
		--1.)VALIDAMOS DEBITO Y CREDITO
	       IF (SELECT SUM(MC_____DEBMONLOC_B)-SUM(MC_____CREMONLOC_B)
			FROM  con.mc_micro____
			WHERE MC_____NUMERO____B =mctype.MC_____NUMERO____B
			      AND MC_____CODIGO____TD_____B=mctype.MC_____CODIGO____TD_____B
			      AND MC_____CODIGO____CD_____B=mctype.MC_____CODIGO____CD_____B ) !=0 THEN


			--1.) insertar en la tabla de log (log_carga_apoteosys)
			INSERT INTO CON.LOG_CARGA_APOTEOSYS(TIPO_DOC, CLASE_DOC, ORDEN_SERVICIO, MENSAJE_ERROR) VALUES(MCTYPE.MC_____CODIGO____TD_____B,
				MCTYPE.MC_____CODIGO____CD_____B,MCTYPE.MC_____NUMERO_OPER_B, 'ERROR, DEBITO Y CREDITO DESCUADRADOS.');

			--2.) borrar registros de la tabla CON.MC____
			DELETE FROM con.mc_micro____ WHERE MC_____NUMERO____B =mctype.MC_____NUMERO____B   AND MC_____CODIGO____TD_____B=mctype.MC_____CODIGO____TD_____B  AND
				MC_____CODIGO____CD_____B=mctype.MC_____CODIGO____CD_____B ;

			--3.) cambiar sw a n
			sw ='N';
		END IF;
	elsif (linea_negocio = 'FAC_NM')then
		--1.)VALIDAMOS DEBITO Y CREDITO
	       IF (SELECT SUM(MC_____DEBMONLOC_B)-SUM(MC_____CREMONLOC_B)
			FROM  con.mc_sl_fac_sel
			WHERE MC_____NUMERO____B = mctype.MC_____NUMERO____B
			      AND MC_____CODIGO____TD_____B=mctype.MC_____CODIGO____TD_____B
			      AND MC_____CODIGO____CD_____B=mctype.MC_____CODIGO____CD_____B ) !=0 THEN


			--1.) insertar en la tabla de log (log_carga_apoteosys)
			INSERT INTO CON.LOG_CARGA_APOTEOSYS(TIPO_DOC, CLASE_DOC, ORDEN_SERVICIO, MENSAJE_ERROR) VALUES(MCTYPE.MC_____CODIGO____TD_____B,
				MCTYPE.MC_____CODIGO____CD_____B,MCTYPE.MC_____REFERENCI_B , 'ERROR, DEBITO Y CREDITO DESCUADRADOS. : '||MCTYPE.MC_____NUMDOCSOP_B);

			--2.) borrar registros de la tabla mc_inversionistas____
			DELETE FROM con.mc_sl_fac_sel WHERE MC_____NUMERO____B =mctype.MC_____NUMERO____B   AND MC_____CODIGO____TD_____B=mctype.MC_____CODIGO____TD_____B  AND
				MC_____CODIGO____CD_____B=mctype.MC_____CODIGO____CD_____B ;

			--3.) cambiar sw a n
			sw ='N';

		END IF;
	elsif (linea_negocio = 'LIBRANZA')then
		--1.)VALIDAMOS DEBITO Y CREDITO
	       IF (SELECT SUM(MC_____DEBMONLOC_B)-SUM(MC_____CREMONLOC_B)
			FROM  con.mc_libranza____
			WHERE MC_____NUMERO____B = mctype.MC_____NUMERO____B
			      AND MC_____CODIGO____TD_____B=mctype.MC_____CODIGO____TD_____B
			      AND MC_____CODIGO____CD_____B=mctype.MC_____CODIGO____CD_____B ) !=0 THEN


			--1.) insertar en la tabla de log (log_carga_apoteosys)
			INSERT INTO CON.LOG_CARGA_APOTEOSYS(TIPO_DOC, CLASE_DOC, ORDEN_SERVICIO, MENSAJE_ERROR) VALUES(MCTYPE.MC_____CODIGO____TD_____B,
				MCTYPE.MC_____CODIGO____CD_____B,MCTYPE.MC_____NUMERO_OPER_B, 'ERROR, DEBITO Y CREDITO DESCUADRADOS.');

			--2.) borrar registros de la tabla CON.MC____
			DELETE FROM con.mc_libranza____ WHERE MC_____NUMERO____B =mctype.MC_____NUMERO____B   AND MC_____CODIGO____TD_____B=mctype.MC_____CODIGO____TD_____B  AND
				MC_____CODIGO____CD_____B=mctype.MC_____CODIGO____CD_____B ;

			--3.) cambiar sw a n
			sw ='N';
		END IF;
	elsif (linea_negocio = 'DIFERIDOS')then
		--1.)VALIDAMOS DEBITO Y CREDITO
	       IF (SELECT SUM(MC_____DEBMONLOC_B)-SUM(MC_____CREMONLOC_B)
			FROM  con.mc_diferidos____
			WHERE MC_____NUMERO____B = mctype.MC_____NUMERO____B
			      AND MC_____CODIGO____TD_____B=mctype.MC_____CODIGO____TD_____B
			      AND MC_____CODIGO____CD_____B=mctype.MC_____CODIGO____CD_____B ) !=0 THEN


			--1.) insertar en la tabla de log (log_carga_apoteosys)
			INSERT INTO CON.LOG_CARGA_APOTEOSYS(TIPO_DOC, CLASE_DOC, ORDEN_SERVICIO, MENSAJE_ERROR) VALUES(MCTYPE.MC_____CODIGO____TD_____B,
				MCTYPE.MC_____CODIGO____CD_____B,MCTYPE.MC_____NUMERO_OPER_B, 'ERROR, DEBITO Y CREDITO DESCUADRADOS.');

			--2.) borrar registros de la tabla CON.MC____
			DELETE FROM con.mc_diferidos____ WHERE MC_____NUMERO____B =mctype.MC_____NUMERO____B   AND MC_____CODIGO____TD_____B=mctype.MC_____CODIGO____TD_____B  AND
				MC_____CODIGO____CD_____B=mctype.MC_____CODIGO____CD_____B ;

			--3.) cambiar sw a n
			sw ='N';
		END IF;
	elsif (linea_negocio IN ('EDUCATIVO','CONSUMO','ENDOSO','AUTOMOTOR','EGRESO_ECA', 'INGRESO_SE'))then
		--1.)VALIDAMOS DEBITO Y CREDITO
	       IF (SELECT SUM(MC_____DEBMONLOC_B)-SUM(MC_____CREMONLOC_B)
			FROM  con.mc_fenalco____
			WHERE MC_____NUMERO____B = mctype.MC_____NUMERO____B
			      AND MC_____CODIGO____TD_____B=mctype.MC_____CODIGO____TD_____B
			      AND MC_____CODIGO____CD_____B=mctype.MC_____CODIGO____CD_____B ) !=0 THEN


			--1.) insertar en la tabla de log (log_carga_apoteosys)
			INSERT INTO CON.LOG_CARGA_APOTEOSYS(TIPO_DOC, CLASE_DOC, ORDEN_SERVICIO, MENSAJE_ERROR) VALUES(MCTYPE.MC_____CODIGO____TD_____B,
				MCTYPE.MC_____CODIGO____CD_____B,MCTYPE.MC_____NUMERO_OPER_B, 'ERROR, DEBITO Y CREDITO DESCUADRADOS.');

			--2.) borrar registros de la tabla CON.MC____
			DELETE FROM con.mc_fenalco____ WHERE MC_____NUMERO____B =mctype.MC_____NUMERO____B   AND MC_____CODIGO____TD_____B=mctype.MC_____CODIGO____TD_____B  AND
				MC_____CODIGO____CD_____B=mctype.MC_____CODIGO____CD_____B ;

			--3.) cambiar sw a n
			sw ='N';
		END IF;
	elsif (linea_negocio = 'ENDEUDAMIENTO')then
		--1.)VALIDAMOS DEBITO Y CREDITO
	       IF (SELECT SUM(MC_____DEBMONLOC_B)-SUM(MC_____CREMONLOC_B)
			FROM  con.mc_endeudamiento____
			WHERE MC_____NUMERO____B = mctype.MC_____NUMERO____B
			      AND MC_____CODIGO____TD_____B=mctype.MC_____CODIGO____TD_____B
			      AND MC_____CODIGO____CD_____B=mctype.MC_____CODIGO____CD_____B ) !=0 THEN


			--1.) insertar en la tabla de log (log_carga_apoteosys)
			INSERT INTO CON.LOG_CARGA_APOTEOSYS(TIPO_DOC, CLASE_DOC, ORDEN_SERVICIO, MENSAJE_ERROR) VALUES(MCTYPE.MC_____CODIGO____TD_____B,
				MCTYPE.MC_____CODIGO____CD_____B,MCTYPE.MC_____NUMERO_OPER_B, 'ERROR, DEBITO Y CREDITO DESCUADRADOS.');

			--2.) borrar registros de la tabla mc_endeudamiento____
			DELETE FROM con.mc_endeudamiento____ WHERE MC_____NUMERO____B =mctype.MC_____NUMERO____B   AND MC_____CODIGO____TD_____B=mctype.MC_____CODIGO____TD_____B  AND
				MC_____CODIGO____CD_____B=mctype.MC_____CODIGO____CD_____B ;

			--3.) cambiar sw a n
			sw ='N';
		END IF;
	elsif (linea_negocio = 'INVERSIONISTAS')then
		--1.)VALIDAMOS DEBITO Y CREDITO
	       IF (SELECT SUM(MC_____DEBMONLOC_B)-SUM(MC_____CREMONLOC_B)
			FROM  con.mc_inversionistas____
			WHERE MC_____NUMERO____B = mctype.MC_____NUMERO____B
			      AND MC_____CODIGO____TD_____B=mctype.MC_____CODIGO____TD_____B
			      AND MC_____CODIGO____CD_____B=mctype.MC_____CODIGO____CD_____B ) !=0 THEN


			--1.) insertar en la tabla de log (log_carga_apoteosys)
			INSERT INTO CON.LOG_CARGA_APOTEOSYS(TIPO_DOC, CLASE_DOC, ORDEN_SERVICIO, MENSAJE_ERROR) VALUES(MCTYPE.MC_____CODIGO____TD_____B,
				MCTYPE.MC_____CODIGO____CD_____B,MCTYPE.MC_____NUMERO_OPER_B, 'ERROR, DEBITO Y CREDITO DESCUADRADOS.');

			--2.) borrar registros de la tabla mc_inversionistas____
			DELETE FROM con.mc_inversionistas____ WHERE MC_____NUMERO____B =mctype.MC_____NUMERO____B   AND MC_____CODIGO____TD_____B=mctype.MC_____CODIGO____TD_____B  AND
				MC_____CODIGO____CD_____B=mctype.MC_____CODIGO____CD_____B ;

			--3.) cambiar sw a n
			sw ='N';
		END IF;
	elsif (linea_negocio = 'RECAUDO')then
		--1.)VALIDAMOS DEBITO Y CREDITO
	       IF (SELECT SUM(MC_____DEBMONLOC_B)-SUM(MC_____CREMONLOC_B)
			FROM con.mc_recaudo____
			WHERE MC_____NUMERO____B = mctype.MC_____NUMERO____B
			      AND MC_____CODIGO____TD_____B=mctype.MC_____CODIGO____TD_____B
			      AND MC_____CODIGO____CD_____B=mctype.MC_____CODIGO____CD_____B ) !=0 THEN


			--1.) insertar en la tabla de log (log_carga_apoteosys)
			INSERT INTO CON.LOG_CARGA_APOTEOSYS(TIPO_DOC, CLASE_DOC, ORDEN_SERVICIO, MENSAJE_ERROR) VALUES(MCTYPE.MC_____CODIGO____TD_____B,
				MCTYPE.MC_____CODIGO____CD_____B,MCTYPE.MC_____NUMERO_OPER_B, 'ERROR, DEBITO Y CREDITO DESCUADRADOS.');

			--2.) borrar registros de la tabla mc_recaudo____
			DELETE FROM con.mc_recaudo____  WHERE MC_____NUMERO____B =mctype.MC_____NUMERO____B   AND MC_____CODIGO____TD_____B=mctype.MC_____CODIGO____TD_____B  AND
				MC_____CODIGO____CD_____B=mctype.MC_____CODIGO____CD_____B ;

			--3.) cambiar sw a n
			sw ='N';
		END IF;
	elsif (linea_negocio = 'FIANZA')then
		--1.)VALIDAMOS DEBITO Y CREDITO
	       IF (SELECT SUM(MC_____DEBMONLOC_B)-SUM(MC_____CREMONLOC_B)
			FROM con.mc_fianza____
			WHERE MC_____NUMERO____B = mctype.MC_____NUMERO____B
			      AND MC_____CODIGO____TD_____B=mctype.MC_____CODIGO____TD_____B
			      AND MC_____CODIGO____CD_____B=mctype.MC_____CODIGO____CD_____B ) !=0 THEN


			--1.) insertar en la tabla de log (log_carga_apoteosys)
			INSERT INTO CON.LOG_CARGA_APOTEOSYS(TIPO_DOC, CLASE_DOC, ORDEN_SERVICIO, MENSAJE_ERROR) VALUES(MCTYPE.MC_____CODIGO____TD_____B,
				MCTYPE.MC_____CODIGO____CD_____B,MCTYPE.MC_____NUMERO_OPER_B, 'ERROR, DEBITO Y CREDITO DESCUADRADOS.');

			--2.) borrar registros de la tabla mc_recaudo____
			DELETE FROM con.mc_fianza____  WHERE MC_____NUMERO____B =mctype.MC_____NUMERO____B   AND MC_____CODIGO____TD_____B=mctype.MC_____CODIGO____TD_____B  AND
				MC_____CODIGO____CD_____B=mctype.MC_____CODIGO____CD_____B ;

			--3.) cambiar sw a n
			sw ='N';
		END IF;
	ELSIF (linea_negocio = 'FAC_CC')then
		IF (SELECT SUM(MC_____DEBMONLOC_B)-SUM(MC_____CREMONLOC_B)
			FROM  con.mc_doc_cxp_cont_fin
			WHERE MC_____NUMERO____B = mctype.MC_____NUMERO____B
			      AND MC_____CODIGO____TD_____B=mctype.MC_____CODIGO____TD_____B
			      AND MC_____CODIGO____CD_____B=mctype.MC_____CODIGO____CD_____B ) !=0 THEN


			--1.) insertar en la tabla de log (log_carga_apoteosys)
			INSERT INTO CON.LOG_CARGA_APOTEOSYS(TIPO_DOC, CLASE_DOC, ORDEN_SERVICIO, MENSAJE_ERROR) VALUES(MCTYPE.MC_____CODIGO____TD_____B,
				MCTYPE.MC_____CODIGO____CD_____B,MCTYPE.MC_____REFERENCI_B , 'ERROR, DEBITO Y CREDITO DESCUADRADOS. : '||MCTYPE.MC_____NUMDOCSOP_B);

			--2.) borrar registros de la tabla mc_inversionistas____
			DELETE FROM con.mc_doc_cxp_cont_fin WHERE MC_____NUMERO____B =mctype.MC_____NUMERO____B   AND MC_____CODIGO____TD_____B=mctype.MC_____CODIGO____TD_____B  AND
				MC_____CODIGO____CD_____B=mctype.MC_____CODIGO____CD_____B ;

			--3.) cambiar sw a n
			sw ='N';

		END IF;
	ELSIF (linea_negocio = 'CD_ENDOSO')then
		IF (SELECT SUM(MC_____DEBMONLOC_B)-SUM(MC_____CREMONLOC_B)
			FROM  con.mc_cd_endoso____
			WHERE MC_____NUMERO____B = mctype.MC_____NUMERO____B
			      AND MC_____CODIGO____TD_____B=mctype.MC_____CODIGO____TD_____B
			      AND MC_____CODIGO____CD_____B=mctype.MC_____CODIGO____CD_____B ) !=0 THEN


			--1.) insertar en la tabla de log (log_carga_apoteosys)
			INSERT INTO CON.LOG_CARGA_APOTEOSYS(TIPO_DOC, CLASE_DOC, ORDEN_SERVICIO, MENSAJE_ERROR) VALUES(MCTYPE.MC_____CODIGO____TD_____B,
				MCTYPE.MC_____CODIGO____CD_____B,MCTYPE.MC_____REFERENCI_B , 'ERROR, DEBITO Y CREDITO DESCUADRADOS. : '||MCTYPE.MC_____NUMDOCSOP_B);

			--2.) borrar registros de la tabla mc_inversionistas____
			DELETE FROM con.mc_cd_endoso____ WHERE MC_____NUMERO____B =mctype.MC_____NUMERO____B   AND MC_____CODIGO____TD_____B=mctype.MC_____CODIGO____TD_____B  AND
				MC_____CODIGO____CD_____B=mctype.MC_____CODIGO____CD_____B ;

			--3.) cambiar sw a n
			sw ='N';

		END IF;
	end if;

	--2.)OTRAS VALIDACIONES


RETURN sw;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.sp_validaciones(con.type_insert_mc, character varying)
  OWNER TO postgres;
