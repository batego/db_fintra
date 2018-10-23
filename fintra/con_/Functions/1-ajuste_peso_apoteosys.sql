-- Function: con.ajuste_peso_apoteosys(numeric, character varying, character varying, character varying, con.type_insert_mc)

-- DROP FUNCTION con.ajuste_peso_apoteosys(numeric, character varying, character varying, character varying, con.type_insert_mc);

CREATE OR REPLACE FUNCTION con.ajuste_peso_apoteosys(_valor_ajuste numeric, _cuenta_ingreso character varying, _cuenta_gasto character varying, _centro_costo character varying, mctype con.type_insert_mc)
  RETURNS text AS
$BODY$

DECLARE
BEGIN

	RAISE NOTICE '_VALOR_AJUSTE: %',_VALOR_AJUSTE;
	MCTYPE.MC_____IDENTIFIC_TERCER_B := '900843992';
        MCTYPE.MC_____SECUINTE__DCD____B := MCTYPE.MC_____SECUINTE__DCD____B +1;--SECUENCIA INTERNA
	MCTYPE.MC_____SECUINTE__B := MCTYPE.MC_____SECUINTE__B+1;       --SECUENCIA INTERNA
	MCTYPE.MC_____CODIGO____CPC____B := (CASE WHEN _VALOR_AJUSTE < 0 THEN _CUENTA_GASTO ELSE _CUENTA_INGRESO END) ;
	MCTYPE.MC_____CODIGO____CU_____B := _CENTRO_COSTO;
	MCTYPE.MC_____DEBMONLOC_B := (CASE WHEN _VALOR_AJUSTE < 0 THEN _VALOR_AJUSTE*-1 ELSE 0.00 END) ;
	MCTYPE.MC_____CREMONLOC_B := (CASE WHEN _VALOR_AJUSTE > 0 THEN _VALOR_AJUSTE ELSE 0.00 END) ;
	MCTYPE.MC_____OBSERVACI_B := 'AJUSTE AL PESO POR DIFERENCIA DE DECIMALES';
	MCTYPE.MC_____CODIGO____DS_____B := '';
	MCTYPE.MC_____NUMDOCSOP_B :='';
	MCTYPE.MC_____NUMEVENC__B := NULL;
	MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
	MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';

	RETURN CON.SP_INSERT_TABLE_MC_DOC_CXP_CONT_FINTRA(MCTYPE);


END
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.ajuste_peso_apoteosys(numeric, character varying, character varying, character varying, con.type_insert_mc)
  OWNER TO postgres;
