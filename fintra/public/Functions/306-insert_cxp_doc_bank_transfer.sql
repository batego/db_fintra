-- Function: insert_cxp_doc_bank_transfer(character varying, character varying, numeric, character varying)

-- DROP FUNCTION insert_cxp_doc_bank_transfer(character varying, character varying, numeric, character varying);

CREATE OR REPLACE FUNCTION insert_cxp_doc_bank_transfer(cxp_doc character varying, bank character varying, valor_cxp numeric, usuario_crea character varying)
  RETURNS text AS
$BODY$
DECLARE
num_serie character varying;
retorno text:='OK';
       
BEGIN	
        SELECT INTO num_serie sp_serie_cxp_transfer();
        --Insertamos cabecera cxp
        INSERT INTO fin.cxp_doc (dstrct, proveedor, tipo_documento, documento, descripcion, agencia, banco, sucursal,vlr_neto, vlr_saldo,
            vlr_neto_me, vlr_saldo_me, tasa, creation_date, creation_user, base, moneda_banco,fecha_documento, fecha_vencimiento, 
            clase_documento_rel, moneda, documento_relacionado,handle_code, fecha_aprobacion, aprobador, usuario_aprobacion)	
	SELECT dstrct, nit_bank, 'FAP', num_serie, 'CXP A '||branch_code||' '||bank_account_no, 'OP', bank, bank_account_no,valor_cxp,
	valor_cxp, valor_cxp, valor_cxp, tasa, now(), usuario_crea, base, moneda_banco,now(),now(), 
		    clase_documento_rel, moneda, documento_relacionado,hc, now(), 'ADMIN', 'ADMIN' from fin.cxp_doc cxp
		    inner join banco_aditional_config bco ON bco.branch_code =  bank
		    where documento = cxp_doc;

        --Insertamos detalle cxp
        INSERT INTO fin.cxp_items_doc(dstrct,proveedor,tipo_documento,documento,item,descripcion,vlr,vlr_me,codigo_cuenta,planilla,
                                      creation_date,creation_user,base,auxiliar)
        SELECT dstrct,nit_bank,'FAP',num_serie,'001','DESEMBOLSO '||nit_bank,valor_cxp,valor_cxp,account_number,
        planilla,now(),usuario_crea,base,auxiliar  FROM fin.cxp_items_doc  inner join banco_aditional_config bco ON bco.branch_code =  bank
        where documento = cxp_doc and planilla != '';

       RETURN retorno;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION insert_cxp_doc_bank_transfer(character varying, character varying, numeric, character varying)
  OWNER TO postgres;
s
