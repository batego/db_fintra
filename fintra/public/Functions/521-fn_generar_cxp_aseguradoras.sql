-- Function: fn_generar_cxp_aseguradoras(character varying, character varying)

-- DROP FUNCTION fn_generar_cxp_aseguradoras(character varying, character varying);

CREATE OR REPLACE FUNCTION fn_generar_cxp_aseguradoras(
    _codigo character varying,
    _usuario character varying)
  RETURNS text AS
$BODY$

DECLARE

	_config_poliza RECORD;
	_detalle_cxp RECORD;
	_resp varchar;
	_compra_cartera varchar;
	_cod_neg varchar;
	_serial varchar;

BEGIN
				select into _cod_neg cod_neg from solicitud_aval where numero_solicitud=_codigo;
				
				for _detalle_cxp in
				select dpn.cod_neg,dpn.item,a.nit,dpn.valor,dpn.fecha_vencimiento
				from administrativo.nueva_configuracion_poliza cp
				inner join administrativo.aseguradoras a on a.id=cp.id_aseguradora
				inner join detalle_poliza_negocio dpn on dpn.id_configuracion_poliza=cp.id
				inner join solicitud_aval sa on sa.numero_solicitud=dpn.cod_neg
				where dpn.cod_neg=_codigo order by a.nit,dpn.item 
				
				loop
				
				select into _serial get_lcod('CXP_POLIZA',_detalle_cxp.item);
				
			    INSERT INTO
			    FIN.CXP_DOC
			    (
			    PROVEEDOR,TIPO_DOCUMENTO,DOCUMENTO,DESCRIPCION,AGENCIA,BANCO,
			    SUCURSAL,VLR_NETO,VLR_SALDO,VLR_NETO_ME,VLR_SALDO_ME,
			    TASA,CREATION_DATE,CREATION_USER, BASE,MONEDA_BANCO,FECHA_DOCUMENTO,FECHA_VENCIMIENTO,
			    CLASE_DOCUMENTO_REL,
			    MONEDA,
			    TIPO_DOCUMENTO_REL,
			    DOCUMENTO_RELACIONADO,
			    HANDLE_CODE,
			    DSTRCT
			    )
			    VALUES
			    (_detalle_cxp.NIT,'FAP',_serial,'CXP - A: '||GET_NOMBP(_detalle_cxp.NIT),'OP',GET_BANCOCXPM(_detalle_cxp.NIT),
			    GET_SUCURSALBANK(_detalle_cxp.NIT),ROUND(_detalle_cxp.valor),ROUND(_detalle_cxp.valor),ROUND(_detalle_cxp.valor),ROUND(_detalle_cxp.valor),
			    1,NOW(),_usuario,'COL','PES',NOW(),_detalle_cxp.fecha_vencimiento::date,'NEG','PES','NEG',_cod_neg,'PZ','FINV');
			    
			
			    INSERT INTO FIN.CXP_ITEMS_DOC
			    (
			    PROVEEDOR,TIPO_DOCUMENTO,DOCUMENTO,ITEM,DESCRIPCION,
			    VLR,
			    VLR_ME,
			    CODIGO_CUENTA,
			    PLANILLA,
			    CREATION_DATE,
			    CREATION_USER,
			    BASE,
			    AUXILIAR,
			    DSTRCT)
			    VALUES
			    (_detalle_cxp.NIT,'FAP',_serial,1,'CXP - A: '||GET_NOMBP(_detalle_cxp.NIT),
			    ROUND(_detalle_cxp.valor),ROUND(_detalle_cxp.valor),28150522,_cod_neg,NOW(),_USUARIO,'COL','AR-'||_detalle_cxp.NIT,'FINV');
			
				UPDATE series 
                set last_number=last_number+1 
                where document_type = 'CXP_POLIZA'
                and reg_status='';
                        
				end loop;
				
			
			
			
				
	RETURN 'OK';

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION fn_generar_cxp_aseguradoras(character varying, character varying)
  OWNER TO postgres;
