-- Function: tem.eg_saldo_liquidador(character varying, character varying)

-- DROP FUNCTION tem.eg_saldo_liquidador(character varying, character varying);

CREATE OR REPLACE FUNCTION tem.eg_saldo_liquidador(_negocio character varying, _periodo character varying)
  RETURNS numeric AS
$BODY$
DECLARE

  retorno numeric:=0.00;

 BEGIN

	retorno:=COALESCE((SELECT (interes+cat) AS valor FROM documentos_neg_aceptado  WHERE reg_status='' AND cod_neg=_negocio AND REPLACE(SUBSTRING(fecha,1,7),'-','')=_periodo  AND documento_cat ='' and causar='S' AND interes_causado =0.00 ),0.00);

	RETURN retorno;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION tem.eg_saldo_liquidador(character varying, character varying)
  OWNER TO postgres;
