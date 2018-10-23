-- Function: con.eg_contabilizacion_automatica_apotesys(character varying)

-- DROP FUNCTION con.eg_contabilizacion_automatica_apotesys(character varying);

CREATE OR REPLACE FUNCTION con.eg_contabilizacion_automatica_apotesys(_linea_negocio character varying)
  RETURNS text AS
$BODY$
DECLARE

--***************************************************************************************************************
-- Funcion .......... con.eg_contabilizacion_automatica_apotesys(_linea_negocio varchar)   			*
-- Objetivo ......... Realizar la contabilizacion automatica desde core fintra para el traslado asia apoteosys	*
-- Parametro ........ linea de negocio	  									*
-- Salida ........... text										        *
-- Fecha ............ 30-10-2017                                                        			*
-- Autor ............ @egonzalez                                        					*
--**************************************************************************************************************

_ENDEUDAMIENTO VARCHAR := 'A-ENDEUDAMIENTO';
_INVERSIONISTA VARCHAR := 'B-INVERSIONISTAS';
_MICROCREDITO VARCHAR := 'C-MICROCREDITO';
_LIBRANZA  VARCHAR := 'D-LIBRANZA';
_EDUCATIVO VARCHAR := 'E-EDUCATIVO';
_CONSUMO VARCHAR := 'F-CONSUMO';
_AUTOMOTOR VARCHAR := 'G-AUTOMOTOR';
_FIANZA VARCHAR :='H-FIANZA';
_DIFERIDOS  VARCHAR := 'I-DIFERIDOS';
_ENDOSO VARCHAR :='J-ENDOSO';
_CAUSACION_INT VARCHAR:='K-CAUSACION_INT';
_RECAUDO VARCHAR :='L-RECAUDO';
_LOGISTICA  VARCHAR := 'M-LOGISTICA';

_idproceso INTEGER :=0;
_spresultado VARCHAR :='FAIL';
_periodo_actual VARCHAR :=REPLACE(SUBSTRING(NOW(),1,7),'-','');
_resultado TEXT;

BEGIN

       --CONTABILIZAR--
	IF(split_part(_linea_negocio, '=>', 1)=_ENDEUDAMIENTO)THEN

		--  --1.)NACIMIENTO DE LA OBLIGACION BANCARIA.
			IF(split_part(_linea_negocio, '=>', 2)='1')THEN

			_idproceso:=tem.guardar_log_apot(1,'FINV',_ENDEUDAMIENTO,'con.interfaz_endedudamiento_desembolso_banco_apoteosys()','',0);
			_spresultado:=con.interfaz_endedudamiento_desembolso_banco_apoteosys();
			_idproceso:=tem.guardar_log_apot(2,'','','',_spresultado,_idproceso);

			END IF;

		--2.)EGRESO.

			IF(split_part(_linea_negocio, '=>', 2)='2')THEN

			_idproceso:=tem.guardar_log_apot(1,'FINV',_ENDEUDAMIENTO,'con.interfaz_endeudamiento_egresos()','',0);
			_spresultado:=con.interfaz_endeudamiento_egresos();
			_idproceso:=tem.guardar_log_apot(2,'','','',_spresultado,_idproceso);

			END IF;

		--3.)CAUSACION NOTAS DEBITOS

			IF(split_part(_linea_negocio, '=>', 2)='3')THEN

			_idproceso:=tem.guardar_log_apot(1,'FINV',_ENDEUDAMIENTO,'con.interfaz_endedudamiento_causacion_apoteosys()','',0);
			_spresultado:= con.interfaz_endedudamiento_causacion_apoteosys();
			_idproceso:=tem.guardar_log_apot(2,'','','',_spresultado,_idproceso);

			END IF;

			_resultado:=_spresultado;

       END IF;

       IF(split_part(_linea_negocio, '=>', 1)=_INVERSIONISTA)THEN

		--1.)INGRESO DE LA INVERSION
			IF(split_part(_linea_negocio, '=>', 2)='1')THEN

			_idproceso:=tem.guardar_log_apot(1,'FINV',_INVERSIONISTA,'con.interfaz_inversionistas_ingreso_apoteosys()','',0);
			_spresultado:=con.interfaz_inversionistas_ingreso_apoteosys();
			_idproceso:=tem.guardar_log_apot(2,'','','',_spresultado,_idproceso);

			END IF;

		--2.)EGRESO DE RETIRO
			IF(split_part(_linea_negocio, '=>', 2)='2')THEN

			_idproceso:=tem.guardar_log_apot(1,'FINV',_INVERSIONISTA,'con.interfaz_inversionistas_egreso_apoteosys()','',0);
			_spresultado:=con.interfaz_inversionistas_egreso_apoteosys();
			_idproceso:=tem.guardar_log_apot(2,'','','',_spresultado,_idproceso);

			END IF;

		--3.)CUSACION CON COMPROBANTE DIARIO
			IF(split_part(_linea_negocio, '=>', 2)='3')THEN

			_idproceso:=tem.guardar_log_apot(1,'FINV',_INVERSIONISTA,'con.interfaz_inversionistas_cdiario_apoteosys()','',0);
			_spresultado:=con.interfaz_inversionistas_cdiario_apoteosys();
			_idproceso:=tem.guardar_log_apot(2,'','','',_spresultado,_idproceso);

			END IF;

			_resultado:=_spresultado;

       END IF;

       IF(split_part(_linea_negocio, '=>', 1)=_MICROCREDITO)THEN

		--1.)NACIMIENTO DEL NEGOCIO MICRO
			IF(split_part(_linea_negocio, '=>', 2)='1')THEN

			_idproceso:=tem.guardar_log_apot(1,'FINV',_MICROCREDITO,'con.interfaz_microcredito_esq_nuevo_apoteosys()','',0);
			_spresultado:=con.interfaz_microcredito_esq_nuevo_apoteosys();
			_idproceso:=tem.guardar_log_apot(2,'','','',_spresultado,_idproceso);

			END IF;

		--2.)EGRESO
			IF(split_part(_linea_negocio, '=>', 2)='2')THEN

			_idproceso:=tem.guardar_log_apot(1,'FINV',_MICROCREDITO,'con.interfaz_microcredito_egreson_apoteosys()','',0);
			_spresultado:=con.interfaz_microcredito_egreson_apoteosys();
			_idproceso:=tem.guardar_log_apot(2,'','','',_spresultado,_idproceso);

			END IF;

		--3.)MI ESQUEMA VIEJO
			IF(split_part(_linea_negocio, '=>', 2)='3')THEN

			_idproceso:=tem.guardar_log_apot(1,'FINV',_MICROCREDITO,'con.interfaz_micro_intereses_mi_mes_apoteosys()','',0);
			_spresultado:=con.interfaz_micro_intereses_mi_mes_apoteosys();
			_idproceso:=tem.guardar_log_apot(2,'','','',_spresultado,_idproceso);

			END IF;

		--4.)CAT ESQUEMA VIEJO

			IF(split_part(_linea_negocio, '=>', 2)='4')THEN

			_idproceso:=tem.guardar_log_apot(1,'FINV',_MICROCREDITO,'con.interfaz_micro_intereses_ca_mes_apoteosys()','',0);
			_spresultado:=con.interfaz_micro_intereses_ca_mes_apoteosys();
			_idproceso:=tem.guardar_log_apot(2,'','','',_spresultado,_idproceso);

			END IF;

			_resultado:=_spresultado;

	END IF;

       IF(split_part(_linea_negocio, '=>', 1)=_LIBRANZA)THEN

		-- --1.)NACIMIENTO DEL NEGOCIO LB LIRANZA
			IF(split_part(_linea_negocio, '=>', 2)='1')THEN

			_idproceso:=tem.guardar_log_apot(1,'FINV',_LIBRANZA,'con.interfaz_libranza_apoteosys()','',0);
			_spresultado:=con.interfaz_libranza_apoteosys();
			_idproceso:=tem.guardar_log_apot(2,'','','',_spresultado,_idproceso);

			END IF;

		--2.)NOTAS DE DESCUENTO
			IF(split_part(_linea_negocio, '=>', 2)='2')THEN

			_idproceso:=tem.guardar_log_apot(1,'FINV',_LIBRANZA,'con.interfaz_libranza_nc_apoteosys()','',0);
			_spresultado:=con.interfaz_libranza_nc_apoteosys();
			_idproceso:=tem.guardar_log_apot(2,'','','',_spresultado,_idproceso);

			END IF;

		--3)EGRESO

			IF(split_part(_linea_negocio, '=>', 2)='3')THEN

			_idproceso:=tem.guardar_log_apot(1,'FINV',_LIBRANZA,'con.interfaz_egresos_lb_apoteosys()','',0);
			_spresultado:=con.interfaz_egresos_lb_apoteosys();
			_idproceso:=tem.guardar_log_apot(2,'','','',_spresultado,_idproceso);

			END IF;

			_resultado:=_spresultado;

       END IF;

        IF(split_part(_linea_negocio, '=>', 1)=_FIANZA)THEN


	--1)MICROCREDITO-FIANZA

		IF(split_part(_linea_negocio, '=>', 2)='1')THEN

		_idproceso:=tem.guardar_log_apot(1,'FINV',_FIANZA,'con.interfaz_fianza_negocios(1)','',0);
		_spresultado:=con.interfaz_fianza_negocios(1);
		_idproceso:=tem.guardar_log_apot(2,'','','',_spresultado,_idproceso);

		END IF;

	--2.)LIBRANZA-FIANZA


		IF(split_part(_linea_negocio, '=>', 2)='2')THEN

		_idproceso:=tem.guardar_log_apot(1,'FINV',_FIANZA,'con.interfaz_fianza_negocios(22)','',0);
		_spresultado:=con.interfaz_fianza_negocios(22);
		_idproceso:=tem.guardar_log_apot(2,'','','',_spresultado,_idproceso);

		END IF;

		_resultado:=_spresultado;


        END IF ;



       IF(split_part(_linea_negocio, '=>', 1)=_EDUCATIVO)THEN
       
       		-- PASO 1
            IF(split_part(_linea_negocio, '=>', 2)='1')THEN

				_idproceso:=tem.guardar_log_apot(1,'FINV',_EDUCATIVO,'CON.INTERFAZ_EDUCATIVO_FINTRA()','',0);
				_spresultado:=CON.INTERFAZ_EDUCATIVO_FINTRA();
				_idproceso:=tem.guardar_log_apot(2,'','','',_spresultado,_idproceso);

			END IF;
       
           --PASO 2
            IF(split_part(_linea_negocio, '=>', 2)='2')THEN

				_idproceso:=tem.guardar_log_apot(1,'FINV',_EDUCATIVO,'CON.INTERFAZ_EGRESOS_FE_APOTEOSYS()','',0);
				_spresultado:=CON.INTERFAZ_EGRESOS_FE_APOTEOSYS();
				_idproceso:=tem.guardar_log_apot(2,'','','',_spresultado,_idproceso);

			END IF;
			
			--PASO 6
		    IF(split_part(_linea_negocio, '=>', 2)='3')THEN

				_idproceso:=tem.guardar_log_apot(1,'FINV',_EDUCATIVO,'CON.INTERFAZ_EDUCATIVO_FIANZA()','',0);
				_spresultado:=CON.INTERFAZ_EDUCATIVO_FIANZA();
				_idproceso:=tem.guardar_log_apot(2,'','','',_spresultado,_idproceso);

			END IF;

			_resultado:=_spresultado;

       END IF;

       IF(split_part(_linea_negocio, '=>', 1)=_CONSUMO)THEN
       
       		--PASO 1
       	    IF(split_part(_linea_negocio, '=>', 2)='1')THEN

				_idproceso:=tem.guardar_log_apot(1,'FINV',_CONSUMO,'CON.INTERFAZ_CONSUMO_FINTRA()','',0);
				_spresultado:=CON.INTERFAZ_CONSUMO_FINTRA();
				_idproceso:=tem.guardar_log_apot(2,'','','',_spresultado,_idproceso);

			END IF;
			
			--PASO 2
			IF(split_part(_linea_negocio, '=>', 2)='2')THEN

				_idproceso:=tem.guardar_log_apot(1,'FINV',_CONSUMO,'CON.INTERFAZ_CONSUMO_NC_COMISION()','',0);
				_spresultado:=CON.INTERFAZ_CONSUMO_NC_COMISION();
				_idproceso:=tem.guardar_log_apot(2,'','','',_spresultado,_idproceso);

			END IF;
			
			--PASO 3
		    IF(split_part(_linea_negocio, '=>', 2)='3')THEN

				_idproceso:=tem.guardar_log_apot(1,'FINV',_CONSUMO,'CON.INTERFAZ_EGRESOS_FC_APOTEOSYS()','',0);
				_spresultado:=CON.INTERFAZ_EGRESOS_FC_APOTEOSYS();
				_idproceso:=tem.guardar_log_apot(2,'','','',_spresultado,_idproceso);

			END IF;
			
			--PASO 7
		    IF(split_part(_linea_negocio, '=>', 2)='4')THEN

				_idproceso:=tem.guardar_log_apot(1,'FINV',_CONSUMO,'CON.INTERFAZ_CONSUMO_FIANZA()','',0);
				_spresultado:=CON.INTERFAZ_CONSUMO_FIANZA();
				_idproceso:=tem.guardar_log_apot(2,'','','',_spresultado,_idproceso);

			END IF;

		_resultado:=_spresultado;

       END IF;

       IF(split_part(_linea_negocio, '=>', 1)=_AUTOMOTOR)THEN
		--1.)NACIMIENTO DEL NEGOCIO FA AUTOMOTOR
		_resultado:=_spresultado;
       END IF;

       IF(split_part(_linea_negocio, '=>', 1)=_DIFERIDOS)THEN

	--1.)DIFERIDOS LIBRANZA (LI) UNIDAD DE NEGOCIO 22
		IF(split_part(_linea_negocio, '=>', 2)='1')THEN

		_idproceso:=tem.guardar_log_apot(1,'FINV',_DIFERIDOS,'con.interfaz_diferidos_apoteosys(22)','',0);
		_spresultado:=con.interfaz_diferidos_apoteosys(22);
		_idproceso:=tem.guardar_log_apot(2,'','','',_spresultado,_idproceso);

		END IF;

	--2.)DIFERIDOS NEGOCIOS MICRO.(MI,CA,CM)

		IF(split_part(_linea_negocio, '=>', 2)='2')THEN

		_idproceso:=tem.guardar_log_apot(1,'FINV',_DIFERIDOS,'con.interfaz_diferidos_apoteosys(1)','',0);
		_spresultado:=con.interfaz_diferidos_apoteosys(1);
		_idproceso:=tem.guardar_log_apot(2,'','','',_spresultado,_idproceso);

		END IF;


		_resultado:=_spresultado;

       END IF;

       IF(split_part(_linea_negocio, '=>', 1)=_ENDOSO)THEN
		_resultado:=_spresultado;

       END IF;

       IF(split_part(_linea_negocio, '=>', 1)=_CAUSACION_INT)THEN
		_resultado:=_spresultado;
       END IF;

       IF(split_part(_linea_negocio, '=>', 1)=_RECAUDO)THEN

		--1.)Pagos micro
		IF(split_part(_linea_negocio, '=>', 2)='1')THEN

 		_idproceso:=tem.guardar_log_apot(1,'FINV',_RECAUDO,'con.interfaz_pagos_x_unidad_apoteosys(''MICROCREDITO'')','',0);
 		_spresultado:=con.interfaz_pagos_x_unidad_apoteosys('MICROCREDITO');
 		_idproceso:=tem.guardar_log_apot(2,'','','',_spresultado,_idproceso);

		END IF;


		--1.)Pagos Libranza
		IF(split_part(_linea_negocio, '=>', 2)='2')THEN

 		_idproceso:=tem.guardar_log_apot(1,'FINV',_RECAUDO,'con.interfaz_pagos_x_unidad_apoteosys(''LIBRANZA'')','',0);
 		_spresultado:=con.interfaz_pagos_x_unidad_apoteosys('LIBRANZA');
 		_idproceso:=tem.guardar_log_apot(2,'','','',_spresultado,_idproceso);

		END IF;

		_resultado:=_spresultado;

       END IF;

       IF(split_part(_linea_negocio, '=>', 1)=_LOGISTICA)THEN

	--1) Anticipos Trasnferencias
		IF(split_part(_linea_negocio, '=>', 2)='1')THEN

		_idproceso:=tem.guardar_log_apot(1,'FINV',_LOGISTICA,'con.interfaz_fintra_logistica_apoteosys_transacciones()','',0);
		_spresultado:=con.interfaz_fintra_logistica_apoteosys_transacciones();
		_idproceso:=tem.guardar_log_apot(2,'','','',_spresultado,_idproceso);

		END IF;

	--2.)Anticipos Pronto Pago
		IF(split_part(_linea_negocio, '=>', 2)='2')THEN

		_idproceso:=tem.guardar_log_apot(1,'FINV',_LOGISTICA,'con.interfaz_fintra_logistica_apoteosys_prontopago()','',0);
		_spresultado:=con.interfaz_fintra_logistica_apoteosys_prontopago();
		_idproceso:=tem.guardar_log_apot(2,'','','',_spresultado,_idproceso);

		END IF;

	--3.1)Anticipos Gasolina paso 1
		IF(split_part(_linea_negocio, '=>', 2)='3')THEN

		_idproceso:=tem.guardar_log_apot(1,'FINV',_LOGISTICA,'con.interfaz_fintra_logistica_apoteosys_gasolina()','',0);
		_spresultado:=con.interfaz_fintra_logistica_apoteosys_gasolina();
		_idproceso:=tem.guardar_log_apot(2,'','','',_spresultado,_idproceso);

		END IF;


	--3.2)Anticipos Gasolina paso 2
		IF(split_part(_linea_negocio, '=>', 2)='4')THEN

		_idproceso:=tem.guardar_log_apot(1,'FINV',_LOGISTICA,'con.interfaz_fintra_logistica_apoteosys_gasolina_eds()','',0);
		_spresultado:=con.interfaz_fintra_logistica_apoteosys_gasolina_eds();
		_idproceso:=tem.guardar_log_apot(2,'','','',_spresultado,_idproceso);

		END IF;

	--4.1)UT

		IF(split_part(_linea_negocio, '=>', 2)='5')THEN

		_idproceso:=tem.guardar_log_apot(1,'FINV',_LOGISTICA,'con.interfaz_fintra_ut_apoteosys_transacciones()','',0);
		_spresultado:=con.interfaz_fintra_ut_apoteosys_transacciones();
		_idproceso:=tem.guardar_log_apot(2,'','','',_spresultado,_idproceso);

		END IF;

		IF(split_part(_linea_negocio, '=>', 2)='6')THEN

		_idproceso:=tem.guardar_log_apot(1,'FINV',_LOGISTICA,'con.interfaz_fintra_ut_apoteosys_egresos()','',0);
		_spresultado:=con.interfaz_fintra_ut_apoteosys_egresos();
		_idproceso:=tem.guardar_log_apot(2,'','','',_spresultado,_idproceso);

		END IF;

		IF(split_part(_linea_negocio, '=>', 2)='7')THEN

		_idproceso:=tem.guardar_log_apot(1,'FINV',_LOGISTICA,'con.interfaz_fintra_ut_apoteosys_cxc()','',0);
		_spresultado:=con.interfaz_fintra_ut_apoteosys_cxc();
		_idproceso:=tem.guardar_log_apot(2,'','','',_spresultado,_idproceso);

		END IF;

		IF(split_part(_linea_negocio, '=>', 2)='8')THEN

		_idproceso:=tem.guardar_log_apot(1,'FINV',_LOGISTICA,'con.interfaz_fintra_ut_apoteosys_ingreso()','',0);
		_spresultado:=con.interfaz_fintra_ut_apoteosys_ingreso();
		_idproceso:=tem.guardar_log_apot(2,'','','',_spresultado,_idproceso);

		END IF;

	--4.)Boton ingreso

       		_resultado:=_spresultado;

       END IF;


	RETURN _resultado;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.eg_contabilizacion_automatica_apotesys(character varying)
  OWNER TO postgres;
