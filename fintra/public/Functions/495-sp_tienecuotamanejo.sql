-- Function: sp_tienecuotamanejo(character varying, character varying, character varying, numeric)

-- DROP FUNCTION sp_tienecuotamanejo(character varying, character varying, character varying, numeric);

CREATE OR REPLACE FUNCTION sp_tienecuotamanejo(_periodofoto character varying, _neg character varying, _cuota character varying, _numciclo numeric)
  RETURNS numeric AS
$BODY$

DECLARE

	ValorSaldoCtaMan numeric := 0;
	_respuesta numeric := 0;

BEGIN

	--CONSULTA NEGOCIO.
	SELECT INTO ValorSaldoCtaMan fcp.valor_saldo
	FROM con.foto_ciclo_pagos fcp
	WHERE fcp.dstrct = 'FINV'
		AND fcp.tipo_documento in ('FAC')
		AND fcp.negasoc = _Neg
		AND fcp.periodo_lote = _PeriodoFoto
		AND fcp.num_doc_fen = _Cuota
		AND substring(fcp.documento,1,2) = 'CM'
		--AND replace(substring(fcp.fecha_vencimiento,1,7),'-','') = _PeriodoFoto
		AND fcp.id_ciclo = _NumCiclo
		AND fcp.valor_saldo > 0;

	_respuesta = coalesce(ValorSaldoCtaMan,0);
	RETURN _respuesta;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_tienecuotamanejo(character varying, character varying, character varying, numeric)
  OWNER TO postgres;
