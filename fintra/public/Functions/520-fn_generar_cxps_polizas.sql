-- Function: fn_generar_cxps_polizas(character varying, character varying, character varying)

-- DROP FUNCTION fn_generar_cxps_polizas(character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION fn_generar_cxps_polizas(
    _cod_negocio character varying,
    _usuario character varying,
    _nit_cliente character varying)
  RETURNS text AS
$BODY$
  
DECLARE
	
	
	_num_cuotas int;	
	_POLIZAS RECORD;
	_CXP RECORD;
	_valor_nc numeric=0;
	_CONT INT =1;
	_SUM_VALOR_POLIZA numeric=0;
	_num_solicitud varchar;
	_cpxs_generado varchar;
 

BEGIN
--1065004669
				
				select into _num_solicitud numero_solicitud from solicitud_aval where cod_neg= _cod_negocio;  
				
				select into _num_cuotas nro_docs from negocios where cod_neg=_cod_negocio;
				
				select into _CXP *  from fin.cxp_doc where documento_relacionado=_cod_negocio and  tipo_documento='FAP' and proveedor=_nit_cliente AND DOCUMENTO NOT ILIKE 'FZ%';
				
				
				--si es tipo cobro anticipado A=anticipado, c=cuotas y en tipo valor porc p=porcentaje y a=absoluto,
				--K=CAPITAL, KI=CAPITAL INTERES Y NLL=NULO
				for _POLIZAS in				
				select cp.id,np.descripcion,tc.tipo as tipo_cobro,tc.financiacion,
				tvp.tipo as tipo_vp,dpn.cod_neg,dpn.valor
				from administrativo.nueva_configuracion_poliza cp
				inner join detalle_poliza_negocio dpn on dpn.id_configuracion_poliza=cp.id
				inner join administrativo.nuevas_polizas np on cp.id_poliza=np.id
				inner join administrativo.tipo_cobro tc on cp.id_tipo_cobro=tc.id 
				inner join administrativo.tipo_valor_poliza tvp on cp.id_valor_poliza=tvp.id
				inner join rel_unidadnegocio_convenios un on un.id_unid_negocio=cp.id_unidad_negocio				
				where dpn.cod_neg=_num_solicitud and tc.tipo='A' and tc.financiacion='N' and cp.reg_status=''
				group by cp.id,np.descripcion,cp.id_unidad_negocio,cp.id_sucursal,tc.tipo,tc.financiacion,
				tvp.tipo ,tvp.calcular_sobre,tvp.valor_absoluto,tvp.valor_porcentaje,dpn.cod_neg,dpn.valor
				
				loop
				
				_valor_nc=_num_cuotas * _POLIZAS.valor;
				
				INSERT INTO FIN.CXP_DOC
				    (
				    PROVEEDOR,TIPO_DOCUMENTO,DOCUMENTO,DESCRIPCION,AGENCIA,HANDLE_CODE,BANCO,
				    SUCURSAL, VLR_NETO, VLR_SALDO, VLR_NETO_ME,VLR_SALDO_ME,TASA,
				    CREATION_DATE,CREATION_USER,BASE,MONEDA_BANCO,FECHA_DOCUMENTO,FECHA_VENCIMIENTO,
				    CLASE_DOCUMENTO_REL,MONEDA,TIPO_DOCUMENTO_REL,DOCUMENTO_RELACIONADO,DSTRCT,
				    CLASE_DOCUMENTO,TIPO_REFERENCIA_1
				    )
				    VALUES
				    (_CXP.PROVEEDOR, 'NC',_CXP.DOCUMENTO||'-FZ'||_CONT,'NC - '||_POLIZAS.descripcion,
				    'OP','AV', GET_BANCOCXPM(_CXP.PROVEEDOR),
				    GET_SUCURSALBANK(_CXP.PROVEEDOR),
				     ROUND(_valor_nc), ROUND(_valor_nc), ROUND(_valor_nc), ROUND(_valor_nc),1,
				    NOW(),_USUARIO,'COL','PES', NOW(),NOW(),4,'PES','FAP',_CXP.DOCUMENTO,'FINV',4,'FACT');	
				    
				    --- RECORDAR VALIDAR EL HC DE LA CUENTA CREADA


				     RAISE NOTICE 'INSERTAMOS DETALLE NC %', _CXP.DOCUMENTO||'-'||_CONT;
				
				    INSERT INTO FIN.CXP_ITEMS_DOC
				    (
				    PROVEEDOR,
				    TIPO_DOCUMENTO,
				    DOCUMENTO,
				    ITEM,
				    DESCRIPCION,
				    VLR,
				    VLR_ME,
				    CODIGO_CUENTA,
				    CREATION_DATE,
				    CREATION_USER,
				    BASE,
				    DSTRCT
				    )
				    VALUES
				    (_CXP.PROVEEDOR,'NC',_CXP.DOCUMENTO||'-FZ'||_CONT,1,'NC - '||_POLIZAS.descripcion,
				    ROUND(_valor_nc),ROUND(_valor_nc),11050534,NOW(),_USUARIO,'COL','FINV');

				
					_CONT=_CONT+1;
					
					_SUM_VALOR_POLIZA=_SUM_VALOR_POLIZA+_valor_nc;
				end loop;
				
				select into _cpxs_generado fn_generar_cxp_aseguradoras(_num_solicitud,_usuario);
		
				

					UPDATE FIN.CXP_DOC  
					SET 					
					VLR_TOTAL_ABONOS = VLR_TOTAL_ABONOS + _SUM_VALOR_POLIZA,
					VLR_SALDO = VLR_SALDO  - _SUM_VALOR_POLIZA,
					VLR_TOTAL_ABONOS_ME= VLR_TOTAL_ABONOS_ME + _SUM_VALOR_POLIZA,
					VLR_SALDO_ME = VLR_SALDO_ME - _SUM_VALOR_POLIZA ,
					LAST_UPDATE=NOW(),
					USER_UPDATE=_USUARIO
					WHERE DOCUMENTO=_CXP.DOCUMENTO AND TIPO_DOCUMENTO='FAP' AND DSTRCT='FINV';
					
					return 'OK';
						
END $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION fn_generar_cxps_polizas(character varying, character varying, character varying)
  OWNER TO postgres;

