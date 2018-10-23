-- Function: get_codigocuenta(text, text, text, text)

-- DROP FUNCTION get_codigocuenta(text, text, text, text);

CREATE OR REPLACE FUNCTION get_codigocuenta(text, text, text, text)
  RETURNS text AS
$BODY$DECLARE
  Pcia             ALIAS FOR $1;
  proveedor       ALIAS FOR $2;
  concept_code    ALIAS FOR $3;
  Pplanilla        ALIAS FOR $4;
  account         TEXT;
  nombretabla     TEXT;
  curTBLCON       REFCURSOR;
  curPLA          REFCURSOR;
  curPRO          REFCURSOR;
  curDM           REFCURSOR;
  regTBLCON       RECORD;
  regPRO          RECORD;
  regPLA          RECORD;
  regDM           RECORD;
  regCOSTO_REMB   RECORD;
  SW              BOOLEAN;
  dummy           TEXT;
  agContable      TEXT;
--**************************************************************************************
-- Funcion .......... get_codigocuenta
-- Objetivo ......... retorna el codigo de cuenta de un proveedor dependiendo
--                           del concept_class de tabla tblcon
-- Parametro 1 ...... Distrito
-- Parametro 2 ...... cedula del proveedor
-- Parametro 3 ...... EL codigo del concepto
-- Parametro 4 ...... El numero de planilla
-- Fecha ............ Abril 3 de 2006
-- Autor ............ Ivan Dario Gomez Vanegas
--**************************************************************************************

BEGIN
    SW = false;
    account := '';
    /*BUSCAMOS EN  TBLCON CON EL CODIGO DE CONCEPTO PASADO POR PARAMETRO*/
    OPEN curTBLCON FOR SELECT * FROM tblcon  t WHERE dstrct = Pcia AND t.concept_code = concept_code;
    FETCH curTBLCON INTO regTBLCON;
    CLOSE curTBLCON;

    /*IF PRINCIPAL,  si el codigo de concepto existe en TBLCON*/
    IF FOUND THEN
       -- RAISE NOTICE  'DISTRITO : % PLANILLA : % PROVEEDOR : % CONCEPTO : %',cia, planilla, proveedor, concept_code;

        /*SI EL CONCEPT_CLASS ES 01, 02, 03  BUSCAMOS LA TABLA CORRESPONDIENTE*/
        IF (regTBLCON.concept_class IN ('01','02','03') )THEN
            nombretabla :=
            CASE WHEN regTBLCON.concept_class = '01' THEN 'proveedor_anticipo'
                 WHEN regTBLCON.concept_class = '02' THEN 'proveedor_acpm'
                 WHEN regTBLCON.concept_class = '03' THEN 'proveedor_tiquetes'
                 ELSE ''
            END;

            RAISE NOTICE  'C_CLASS : % NOMBRETABLA : %', regTBLCON.concept_class, nombretabla;
            OPEN curPRO FOR EXECUTE
                'SELECT  * FROM '|| nombretabla ||'  p WHERE p.dstrct = \''|| Pcia ||'\'AND p.nit = \''|| proveedor ||'\' AND p.concept_code = \'' || regTBLCON.concept_class || '\' AND p.account != \'\'';

  	    FETCH curPRO INTO regPRO;
	    CLOSE curPRO;
	    IF FOUND THEN
	        account := regPRO.account;
		SW      := true;
	    END IF;
	END IF;
       /*FIN  IF (regTBLCON.concept_class IN ('01','02','03') )THEN */



       IF NOT SW THEN
          --  RAISE NOTICE  'ENTRO AL BLOQUE : ';
            /*Busco en costo_reembolsables*/
            SELECT INTO regCOSTO_REMB reembolsable, nit, cuenta1, cuenta2
            FROM  costo_reembolsables
		WHERE
		    dstrct = Pcia
		AND codigo = concept_code
		AND numpla = Pplanilla
		LIMIT 1;

             /*SI*/
             IF FOUND THEN
                  RAISE NOTICE  'ENTRO AL BLOQUE 2 : ';
                 IF regCOSTO_REMB.reembolsable ='S' THEN
                     account :=  regCOSTO_REMB.cuenta1 || ';IT-' || regCOSTO_REMB.nit;

                 ELSIF regCOSTO_REMB.reembolsable ='N' OR regCOSTO_REMB.reembolsable ='' THEN
                     account :=  regCOSTO_REMB.cuenta1;
                 END IF;

             ELSE
                --  RAISE NOTICE  'ENTRO AL BLOQUE 3 : ';
                  /*Si ingreso_costo ='C' se se almacena en la variable dummy el substr(p.account_code_c,1,9)
		    sino se almacena en  la variable dummy el substr(p.account_code_i,1,9) */
		   IF ( regTBLCON.ingreso_costo = 'C') THEN
		       SELECT INTO dummy COALESCE(substr(p.account_code_c,1,9),'') as ac FROM plarem p WHERE p.cia = Pcia AND p.numpla = Pplanilla;
		   ELSE
		       SELECT INTO dummy COALESCE(substr(p.account_code_i,1,9),'') as ac FROM plarem p WHERE p.cia = Pcia AND p.numpla = Pplanilla;
		   END IF;

		   IF FOUND THEN
		       /*Si el campo tipo cuenta de tblcon es igual a 'E', retornamos el dummy  concatenado con el account de tblcon*/
		       IF regTBLCON.tipocuenta ='E' THEN
			   account := dummy || regTBLCON.account;
			   RAISE NOTICE 'CUENTA : % ', account;

                           IF (regTBLCON.account != '9005' AND regTBLCON.ingreso_costo = 'C' ) THEN

				   SELECT INTO agContable  b.table_code
					FROM    planilla a,
						tablagen b
					WHERE
					      a.cia        = Pcia
					AND   a.numpla     = Pplanilla
					AND   a.agcpla     = b.referencia
					AND   b.table_type ='TAGECONT';

				   IF FOUND THEN
				       account := substr(account,1,1) ||  agContable || substr(account,4,LENGTH(account)- 3);

				   END IF;


                            END IF;


		       /*Si el campo tipo cuenta de tblcon  igual a 'C' retornamos el account de tblcon*/
		       ELSIF regTBLCON.tipocuenta ='C' THEN
			   account := regTBLCON.account;

		       /*Si el campo tipo cuenta de tblcon  igual a 'Q' buscamos en descuento_mantenimiento clase_equipo y  num_equipo*/
		       ELSIF regTBLCON.tipocuenta ='Q' THEN
			   OPEN curDM FOR SELECT * FROM descuento_mantenimiento dm  WHERE  dm.dstrct = Pcia AND dm.numpla = Pplanilla AND dm.codigo_concepto = concept_code;

			   FETCH curDM INTO regDM;
			   CLOSE curDM;
			       IF FOUND THEN
				   /*si en contramos armamos la cuenta de la sig. manera:*/
				   account := substr(regTBLCON.account,1,4) || regDM.clase_equipo || regDM.num_equipo || substr(regTBLCON.account,5,4);
			       END IF;
		       END IF;
		   END IF;/*FIN  IF FOUND THEN*/

             END IF;



       END IF;/*IF NOT SW THEN*/


    END IF;/*FIN IF PRINCIPAL*/

    RETURN account;
END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_codigocuenta(text, text, text, text)
  OWNER TO postgres;
