-- Function: sp_cuotamanejo(character varying, character varying)

-- DROP FUNCTION sp_cuotamanejo(character varying, character varying);

CREATE OR REPLACE FUNCTION sp_cuotamanejo(_neg character varying, _cuota character varying)
  RETURNS numeric AS
$BODY$

DECLARE

	ValorSaldoCtaMan numeric := 0;
	_respuesta numeric := 0;

BEGIN

	--CONSULTA NEGOCIO.
	SELECT INTO ValorSaldoCtaMan fcp.valor_saldo
	FROM con.factura fcp
	WHERE fcp.dstrct = 'FINV'
		AND fcp.tipo_documento in ('FAC')
		AND fcp.negasoc = _Neg
		AND fcp.num_doc_fen = _Cuota
		AND substring(fcp.documento,1,2) = 'CM'
		--AND replace(substring(fcp.fecha_vencimiento,1,7),'-','') = _PeriodoFoto
		AND fcp.valor_saldo > 0;

	_respuesta = coalesce(ValorSaldoCtaMan,0);
	RETURN _respuesta;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_cuotamanejo(character varying, character varying)
  OWNER TO postgres;
