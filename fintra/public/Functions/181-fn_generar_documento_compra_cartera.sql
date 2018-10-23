-- Function: fn_generar_documento_compra_cartera(character varying, character varying, character varying)

-- DROP FUNCTION fn_generar_documento_compra_cartera(character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION fn_generar_documento_compra_cartera(_negocio character varying, _idconvenio character varying, _usuario character varying)
  RETURNS text AS
$BODY$

DECLARE

	_OBLIGACIONESCOMPRAR RECORD;
	_CONVENIO RECORD;
	DEDUCCIONES RECORD;
	_CPXNEGOCIO RECORD;
	_APROBADOR VARCHAR;
	_SERIAL VARCHAR;
	_VR_DESEMBOLSO NUMERIC;
	VALORDEDUCCION NUMERIC;
	SUMDEDUCCIONCC NUMERIC:=0;
	SUMDEVALORCOMPRA NUMERIC:=0;
	_CONT INTEGER:=1;
	_TOTALCOMPRAR NUMERIC:=0;



BEGIN
	SELECT INTO _VR_DESEMBOLSO VR_DESEMBOLSO FROM NEGOCIOS WHERE COD_NEG= _NEGOCIO;

	SELECT INTO _CPXNEGOCIO * FROM FIN.CXP_DOC WHERE DOCUMENTO_RELACIONADO=_NEGOCIO AND  DOCUMENTO ILIKE 'MP%' AND  REFERENCIA_2='';

	SELECT INTO _CONVENIO * FROM CONVENIOS WHERE ID_CONVENIO=_IDCONVENIO;

	SELECT INTO _APROBADOR TABLE_CODE FROM TABLAGEN WHERE TABLE_TYPE='AUTCXP' AND DATO='PREDETERMINADO';

	SELECT INTO _TOTALCOMPRAR SUM(SOC.VALOR_COMPRAR)
	FROM SOLICITUD_AVAL SA
	INNER JOIN SOLICITUD_OBLIGACIONES_COMPRAR SOC ON SOC.NUMERO_SOLICITUD=SA.NUMERO_SOLICITUD
	INNER JOIN NEGOCIOS N ON SA.COD_NEG=N.COD_NEG
        WHERE SA.COD_NEG=_NEGOCIO;

	IF _TOTALCOMPRAR < _VR_DESEMBOLSO THEN

	FOR _OBLIGACIONESCOMPRAR IN

	SELECT SOC.*,N.COD_CLI
	FROM SOLICITUD_AVAL SA
	INNER JOIN SOLICITUD_OBLIGACIONES_COMPRAR SOC ON SOC.NUMERO_SOLICITUD=SA.NUMERO_SOLICITUD
	INNER JOIN NEGOCIOS N ON SA.COD_NEG=N.COD_NEG
        WHERE SA.COD_NEG=_NEGOCIO

	LOOP


			   SELECT INTO _SERIAL GET_LCOD(_CONVENIO.PREFIJO_CXP);

			    RAISE NOTICE 'INSERTAMOS CABECERA DE CXP %', _SERIAL;

			    RAISE NOTICE '_CPXNEGOCIO,VALOR_NETO: %', _CPXNEGOCIO.VLR_NETO;

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
			    DSTRCT,
			    FECHA_APROBACION,
			    APROBADOR,
			    USUARIO_APROBACION,
			    TIPO_REFERENCIA_2,
			    REFERENCIA_2,
			    TIPO_REFERENCIA_3,
			    REFERENCIA_3
			    )
			    VALUES
			    (_OBLIGACIONESCOMPRAR.NIT_ENTIDAD,'FAP',_SERIAL,'CXP - CHEQUE A: '||GET_NOMBP(_OBLIGACIONESCOMPRAR.NIT_ENTIDAD),'OP',GET_BANCOCXPM(_OBLIGACIONESCOMPRAR.NIT_ENTIDAD),
			    GET_SUCURSALBANK(_OBLIGACIONESCOMPRAR.NIT_ENTIDAD),ROUND(_OBLIGACIONESCOMPRAR.VALOR_COMPRAR),ROUND(_OBLIGACIONESCOMPRAR.VALOR_COMPRAR),ROUND(_OBLIGACIONESCOMPRAR.VALOR_COMPRAR)
			    ,ROUND(_OBLIGACIONESCOMPRAR.VALOR_COMPRAR),1,NOW(),_USUARIO,'COL','PES',NOW(),NOW(),'NEG','PES','NEG',_NEGOCIO,_CONVENIO.HC_CXP,'FINV',NOW(),_APROBADOR,_USUARIO,'REL',_CPXNEGOCIO.DOCUMENTO,'DESEM','CHEQUE');

			    RAISE NOTICE 'INSERTAMOS DETALLE DE CXP %', _SERIAL;

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
			    PLANILLA,
			    CREATION_DATE,
			    CREATION_USER,
			    BASE,
			    AUXILIAR,
			    DSTRCT)
			    VALUES
			    (_OBLIGACIONESCOMPRAR.NIT_ENTIDAD,'FAP',_SERIAL,1,'DESEMBOLSO - CHEQUE A: '||_OBLIGACIONESCOMPRAR.COD_CLI||_OBLIGACIONESCOMPRAR.NIT_ENTIDAD,
			    ROUND(_OBLIGACIONESCOMPRAR.VALOR_COMPRAR),ROUND(_OBLIGACIONESCOMPRAR.VALOR_COMPRAR),_CONVENIO.CUENTA_CXP,_NEGOCIO,NOW(),_USUARIO,'COL','AR-'||_OBLIGACIONESCOMPRAR.NIT_ENTIDAD,'FINV');

			    SUMDEVALORCOMPRA=SUMDEVALORCOMPRA+_OBLIGACIONESCOMPRAR.VALOR_COMPRAR;

			    RAISE NOTICE 'SUMDEVALORCOMPRA:  %', SUMDEVALORCOMPRA;


			FOR DEDUCCIONES IN

				SELECT *,
				(SELECT CUENTA_DETALLE FROM OPERACIONES_LIBRANZA WHERE ID = DEDUCCIONES_MICROCREDITO.ID_OPERACION_LIBRANZA) AS CUENTA_DETALLE
				FROM DEDUCCIONES_MICROCREDITO
				WHERE _VR_DESEMBOLSO BETWEEN DESEMBOLSO_INICIAL AND DESEMBOLSO_FINAL
			        AND  ID_OCUPACION_LABORAL = 1
			        AND  REG_STATUS=''
			LOOP


				    IF ( DEDUCCIONES.VALOR_COBRAR != 0 ) THEN
				    VALORDEDUCCION = DEDUCCIONES.VALOR_COBRAR;
				    END IF;

				    IF ( DEDUCCIONES.PERC_COBRAR != 0 ) THEN
				    VALORDEDUCCION = (_OBLIGACIONESCOMPRAR.VALOR_COMPRAR * (DEDUCCIONES.PERC_COBRAR/100));
				    END IF;

				    IF ( DEDUCCIONES.N_XMIL != 0 ) THEN
				    VALORDEDUCCION = ((_OBLIGACIONESCOMPRAR.VALOR_COMPRAR/1000)*DEDUCCIONES.N_XMIL);
				    END IF;



				    RAISE NOTICE 'INSERTAMOS CABECERA NC %', _SERIAL||_CONT;

				    INSERT INTO FIN.CXP_DOC
				    (
				    PROVEEDOR,TIPO_DOCUMENTO,DOCUMENTO,DESCRIPCION,AGENCIA,HANDLE_CODE,BANCO,
				    SUCURSAL, VLR_NETO, VLR_SALDO, VLR_NETO_ME,VLR_SALDO_ME,TASA,
				    CREATION_DATE,CREATION_USER,BASE,MONEDA_BANCO,FECHA_DOCUMENTO,FECHA_VENCIMIENTO,
				    CLASE_DOCUMENTO_REL,MONEDA,TIPO_DOCUMENTO_REL,DOCUMENTO_RELACIONADO,DSTRCT,
				    CLASE_DOCUMENTO,TIPO_REFERENCIA_1
				    )
				    VALUES
				    (_OBLIGACIONESCOMPRAR.NIT_ENTIDAD, 'NC',_CPXNEGOCIO.DOCUMENTO||'-'||_CONT,'NC - '|| DEDUCCIONES.DESCRIPCION,
				    'OP',_CONVENIO.HC_CXP, GET_BANCOCXPM(_OBLIGACIONESCOMPRAR.NIT_ENTIDAD),
				    GET_SUCURSALBANK(_OBLIGACIONESCOMPRAR.NIT_ENTIDAD),
				     ROUND(VALORDEDUCCION), ROUND(VALORDEDUCCION), ROUND(VALORDEDUCCION), ROUND(VALORDEDUCCION),1,
				    NOW(),_USUARIO,'COL','PES', NOW(),NOW(),4,'PES','FAP',_CPXNEGOCIO.DOCUMENTO,'FINV',4,'FACT');


				     RAISE NOTICE 'INSERTAMOS DETALLE NC %', _SERIAL||'-1';

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
				    (_OBLIGACIONESCOMPRAR.NIT_ENTIDAD,'NC',_CPXNEGOCIO.DOCUMENTO||'-'||_CONT,1,'NC - '|| DEDUCCIONES.DESCRIPCION,
				    ROUND(VALORDEDUCCION),ROUND(VALORDEDUCCION),_CONVENIO.CUENTA_CXP,NOW(),_USUARIO,'COL','FINV');



				    SUMDEDUCCIONCC= SUMDEDUCCIONCC + VALORDEDUCCION;

				    RAISE NOTICE '_OBLIGACIONESCOMPRAR.VALOR_COMPRAR: %',_OBLIGACIONESCOMPRAR.VALOR_COMPRAR;
				    RAISE NOTICE 'VALORDEDUCCION: %',VALORDEDUCCION;
				    RAISE NOTICE 'SUMDEDUCCIONCC: %',SUMDEDUCCIONCC;

				    _CONT=_CONT+1;
			END LOOP;

	END LOOP;



			UPDATE FIN.CXP_DOC
			SET
			VLR_NETO = VLR_NETO - SUMDEVALORCOMPRA ,
			VLR_NETO_ME = VLR_NETO_ME - SUMDEVALORCOMPRA ,
			VLR_TOTAL_ABONOS = VLR_TOTAL_ABONOS + SUMDEDUCCIONCC,
			VLR_SALDO = VLR_SALDO  - ( SUMDEVALORCOMPRA + SUMDEDUCCIONCC) ,
			VLR_TOTAL_ABONOS_ME= VLR_TOTAL_ABONOS_ME + SUMDEDUCCIONCC,
			VLR_SALDO_ME = VLR_SALDO_ME - ( SUMDEVALORCOMPRA + SUMDEDUCCIONCC) ,
			LAST_UPDATE=NOW(),
			USER_UPDATE=_USUARIO
			WHERE DOCUMENTO=_CPXNEGOCIO.DOCUMENTO AND TIPO_DOCUMENTO='FAP' AND DSTRCT='FINV';

			UPDATE FIN.CXP_ITEMS_DOC
			SET
			VLR = VLR - SUMDEVALORCOMPRA ,
			VLR_ME = VLR_ME - SUMDEVALORCOMPRA ,
			LAST_UPDATE=NOW(),
			USER_UPDATE=_USUARIO
			WHERE DOCUMENTO=_CPXNEGOCIO.DOCUMENTO AND PLANILLA=_NEGOCIO AND TIPO_DOCUMENTO='FAP' AND DSTRCT='FINV';



			UPDATE FIN.CXP_DOC
			SET REFERENCIA_3='TRANSFERENCIA'
			WHERE DOCUMENTO=_CPXNEGOCIO.DOCUMENTO AND DOCUMENTO_RELACIONADO=_NEGOCIO;


	RETURN 'DOCUMENTOS GENERADOS';

	ELSE
	RETURN 'EL VALOR DE LA COMPRA DE CARTERA SUPERA EL MONTO A TRANSFERIR';
	END IF;



END $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION fn_generar_documento_compra_cartera(character varying, character varying, character varying)
  OWNER TO postgres;
