-- Function: eg_vlrs_liq_cuota(text, character varying, integer)

-- DROP FUNCTION eg_vlrs_liq_cuota(text, character varying, integer);

CREATE OR REPLACE FUNCTION eg_vlrs_liq_cuota(codneg text, concepto character varying, cuota integer)
  RETURNS numeric AS
$BODY$
DECLARE

  _valor numeric:=0.00;
  _recordLiquidador record;



BEGIN


    SELECT INTO _recordLiquidador cod_neg, item, fecha, dias, saldo_inicial, capital, interes,
	   valor, saldo_final, reg_status, creation_date, no_aval, capacitacion,
	   cat, seguro, interes_causado, fch_interes_causado, documento_cat,
	   custodia, remesa, causar, dstrct, tipo, cuota_manejo, cuota_manejo_causada,
           fch_cuota_manejo_causada, causar_cuota_admin
     FROM documentos_neg_aceptado
     WHERE cod_neg=codneg AND reg_sTatus='' and item=cuota;

     _valor:=CASE WHEN concepto='CAPITAL'THEN _recordLiquidador.capital
		  WHEN concepto='INTERES'THEN _recordLiquidador.interes
		  WHEN concepto='CAT'THEN _recordLiquidador.cat
		  WHEN concepto='SEGURO'THEN _recordLiquidador.seguro
		  WHEN concepto='CUOTA-ADMINISTRACION'THEN _recordLiquidador.cuota_manejo
		  WHEN concepto='VALOR-CUOTA'THEN _recordLiquidador.valor
		 ELSE 0
	       END;

    RETURN _valor;

END;$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_vlrs_liq_cuota(text, character varying, integer)
  OWNER TO postgres;
