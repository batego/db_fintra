-- Function: etes.ia_cxc_transportadoras_corrida(character varying, character varying)

-- DROP FUNCTION etes.ia_cxc_transportadoras_corrida(character varying, character varying);

CREATE OR REPLACE FUNCTION etes.ia_cxc_transportadoras_corrida(fechacorrida character varying, usuario character varying)
  RETURNS boolean AS
$BODY$
DECLARE

 rs boolean :=false;
 recordFacturas record;
 validarCabecera boolean:=true;
 numeroIA varchar:='';
 items integer:=0;
 vectorCuentas varchar[]='{}';
 valor_nota numeric:=0;

BEGIN



    /****************************************************************************************************
    ************ 1.) BUSAMOS LAS FACTURAS PARA NOTA DE AJUSTE DE DESCARGUE CXC A TRANSPORTADORA ********/


    --falata la cuenta hc
    FOR recordFacturas IN  SELECT (SELECT cuenta FROM con.cmc_doc where cmc =fac.cmc and tipodoc='FAC') as cuenta,
				* FROM con.factura fac
				WHERE fac.valor_saldo > 0
				AND fac.tipo_documento='FAC'
				AND fac.reg_status !='A'
				AND fac.tipo_referencia_1='FCORR'
				AND fac.referencia_1::date=fechacorrida::date
    LOOP

		raise notice 'xxx';
                items:=items+1;
                --VALIDAR CABECERA
                IF(validarCabecera)THEN
			validarCabecera:=false;
                        SELECT INTO numeroIA get_lcod('ICAC');
                        RAISE NOTICE 'NUMERO DE IA : %',numeroIA;

			vectorCuentas:=etes.get_cuentas_perfil('IA_TRANSPORTADORA');
			RAISE NOTICE 'CUENTA CABECERA : vectorCuentas[1]: %', vectorCuentas[1] ;
			/****************************************************
			************* 1.) CABECERA DE LA IA *****************/

			INSERT INTO con.ingreso(dstrct,tipo_documento,num_ingreso,codcli,nitcli,
				     concepto,tipo_ingreso,fecha_consignacion,fecha_ingreso,branch_code,
				     bank_account_no,codmoneda,agencia_ingreso,descripcion_ingreso,vlr_ingreso,
				     vlr_ingreso_me,vlr_tasa,fecha_tasa,cant_item,creation_user,
				     creation_date,base,cuenta)

			VALUES('FINV','ICA',numeroIA,recordFacturas.codcli,recordFacturas.nit,
			       'FE','C',now(),now(),'CAJA TESORERIA',
			       'BARRANQUILLA','PES','OP','CONTRAPARTIDA PARA LA CXC INDIVIDUAL A TRANSPORTADORA',1,
			       1,'1.000000',substring(now(),1,10)::date,1,usuario,
			       now(),'COL', vectorCuentas[1]);

                END IF;

		--GENERA EL DETALLE DEL DOCUMENTO DE INGRESO (NOTA AJUSTE INDEMNIZADA u ORDEN)
			INSERT INTO con.ingreso_detalle	(dstrct,tipo_documento,	num_ingreso,item,nitcli,
							valor_ingreso,valor_ingreso_me,factura,fecha_factura,tipo_doc,
							documento,creation_user,creation_date,base,cuenta,descripcion,
							valor_tasa,saldo_factura)
			VALUES('FINV','ICA',numeroIA,items,recordFacturas.nit,
				recordFacturas.valor_saldo,recordFacturas.valor_saldo,recordFacturas.documento,recordFacturas.fecha_factura,'FAC',
				recordFacturas.documento,usuario,now(),'COL',recordFacturas.cuenta,
				recordFacturas.descripcion,'1.0000000000',recordFacturas.valor_saldo);

		raise notice 'entra a  update : %',recordFacturas.documento;

		--ACTUALIZAR SALDOS POR FACTURA.
	        UPDATE con.factura SET
			valor_abono = valor_factura,
			valor_saldo = 0 ,
			valor_abonome = valor_factura,
			valor_saldome = 0,
			user_update=usuario,
			last_update=now(),
			tipo_documento_ultimo_ingreso='ING',
			num_ingreso_ultimo_ingreso=numeroIA,
			item_ultimo_ingreso = 1
		WHERE documento = recordFacturas.documento;

		raise notice 'FIN UPDATE '  ;

		rs:=true;

	END LOOP;

	/****************************************************
	********ACTUALIZAMOS LA CABECERA DEL LOS INGRESOS***/

        SELECT INTO valor_nota coalesce(sum(valor_ingreso),0) FROM con.ingreso_detalle WHERE num_ingreso =numeroIA;

	IF(numeroIA !='' AND valor_nota > 0 )THEN

          UPDATE con.ingreso
		SET vlr_ingreso =valor_nota,
		vlr_ingreso_me = valor_nota,
		cant_item= items
	  WHERE num_ingreso = numeroIA;

        END IF;

	RETURN rs;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION etes.ia_cxc_transportadoras_corrida(character varying, character varying)
  OWNER TO postgres;
