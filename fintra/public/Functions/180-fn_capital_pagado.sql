-- Function: fn_capital_pagado(character varying, character varying, date)

-- DROP FUNCTION fn_capital_pagado(character varying, character varying, date);

CREATE OR REPLACE FUNCTION fn_capital_pagado(_negocio character varying, _nit_proveedor character varying, _fecha_corte date)
  RETURNS text AS
$BODY$

DECLARE

	_VALOR_UNITARIO varchar;
BEGIN



	SELECT INTO _VALOR_UNITARIO coalesce(sum(fd.valor_unitario),0)
	FROM CON.FACTURA F 
	INNER JOIN CON.FACTURA_DETALLE FD ON F.DOCUMENTO=FD.DOCUMENTO
	WHERE F.VALOR_ABONO!=0  AND F.NEGASOC=_negocio AND F.NIT=_nit_proveedor AND FD.DESCRIPCION='CAPITAL';

	return _VALOR_UNITARIO;

END $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION fn_capital_pagado(character varying, character varying, date)
  OWNER TO postgres;
