-- Function: crear_nc_consumo_fintra(character varying, character varying)

-- DROP FUNCTION crear_nc_consumo_fintra(character varying, character varying);

CREATE OR REPLACE FUNCTION crear_nc_consumo_fintra(_documento character varying, _convenio character varying)
  RETURNS text AS
$BODY$

DECLARE
	_CXP RECORD;
	_DEDUCCION RECORD;
BEGIN


		--SELECT INTO SERIAL PREFIX||LPAD(LAST_NUMBER, 9, '0') FROM SERIES WHERE DOCUMENT_TYPE = 'FAC' AND ID=1391 AND REG_STATUS='';

		SELECT INTO _DEDUCCION * FROM DEDUCCIONES_FINTRA WHERE  ID_CONVENIO=_DEDUCCION;

		SELECT INTO _CXP * FROM FIN.CXP_DOC WHERE DOCUMENTO=_documento;

		IF CXP_ IS NOT NULL THEN

		RAISE NOTICE 'SE INICIA CREACION DE NOTA CREDITO A %',_CXP.PROVEEDOR;
			insert into
			    fin.cxp_doc
			    (
			    proveedor,
			    tipo_documento,
			    documento,
			    descripcion,
			    agencia,
			    handle_code,
			    banco,
			    sucursal,
			    vlr_neto,
			    vlr_saldo,
			    vlr_neto_me,
			    vlr_saldo_me,
			    tasa,
			    creation_date,
			    creation_user,
			    base,
			    moneda_banco,
			    fecha_documento,
			    fecha_vencimiento,
			    clase_documento_rel,
			    moneda,
			    tipo_documento_rel,
			    documento_relacionado,
			    dstrct
		    ) values
			    (_CXP.proveedor,
			    'NC',
			    _documento||'_1',
			    'NC A'||get_nombp(_CXP.proveedor),
			    'OP',
			    'HC',
			    get_bank(_CXP.proveedor),
			    get_bank1(_CXP.proveedor),
			    round(_CXP.vlr_neto),
			    round(_CXP.vlr_saldo),
			    round(_CXP.vlr_neto_me),
			    round(_CXP.vlr_saldo_me),
			    1,
			    NOW(),
			    _CXP.creation_user,
			    'COL',
			    'PES',
			    NOW(),
			    NOW(),
			    'FAP',
			    'PES',
			    'FAP',
			    _CXP.DOCUMENTO,
			    _CXP.dstrct);

		RETURN 'SE CREO NC: '||_documento||'_1';

		ELSE

		RETURN 'EL DOCUMENTO: '||_CXP.DOCUMENTO||' NO EXISTE';


		END IF;


						-- UPDATE SERIES SET LAST_NUMBER = LAST_NUMBER+1 WHERE DOCUMENT_TYPE = 'FAC' AND ID=1391 AND REG_STATUS = '';
--
-- 						RAISE NOTICE 'SE CREO CXC:% PROVEEDOR: %',SERIAL,CXP_.PROVEEDOR;
--
-- 						RETURN 'SE CREO CXC '|| SERIAL;

END $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION crear_nc_consumo_fintra(character varying, character varying)
  OWNER TO postgres;
