-- Function: sp_cuotamanejofactura(character varying, character varying)

-- DROP FUNCTION sp_cuotamanejofactura(character varying, character varying);

CREATE OR REPLACE FUNCTION sp_cuotamanejofactura(_neg character varying, _cuota character varying)
  RETURNS numeric AS
$BODY$

DECLARE

	ValorSaldoCtaMan numeric := 0;
	_respuesta numeric := 0;

BEGIN

	--CONSULTA NEGOCIO.
	SELECT INTO ValorSaldoCtaMan valor_unitario
	FROM con.factura fcp
	INNER JOIN con.factura_detalle fd ON fd.documento = fcp.documento
	INNER JOIN documentos_neg_aceptado dna ON dna.cod_neg = fcp.negasoc
	WHERE fcp.dstrct = 'FINV'
		AND fcp.tipo_documento in ('FAC')
		AND fcp.negasoc = _Neg
		AND dna.item = _Cuota
		AND  fd.descripcion = 'CUOTA-ADMINISTRACION'
		AND fcp.valor_saldo > 0
		group by valor_unitario;

	_respuesta = coalesce(ValorSaldoCtaMan,0);
	RETURN _respuesta;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION sp_cuotamanejofactura(character varying, character varying)
  OWNER TO postgres;
