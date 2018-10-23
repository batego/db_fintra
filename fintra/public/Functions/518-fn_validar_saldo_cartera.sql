-- Function: fn_validar_saldo_cartera(character varying, character varying, character varying, date)

-- DROP FUNCTION fn_validar_saldo_cartera(character varying, character varying, character varying, date);

CREATE OR REPLACE FUNCTION fn_validar_saldo_cartera(
    _negocio character varying,
    _nit_proveedor character varying,
    _periodo character varying,
    _fecha_corte date)
  RETURNS text AS
$BODY$
  
DECLARE
	
	
	_saldo numeric;
	_interes numeric;
	_total numeric;
 

BEGIN

			
		
		SELECT coalesce(sum(f.valor_saldo),0)
		into _saldo
		FROM CON.FOTO_CARTERA F 
		INNER JOIN CON.FACTURA_DETALLE FD ON F.DOCUMENTO=FD.DOCUMENTO
		WHERE F.VALOR_ABONO!=0  AND F.NEGASOC=_negocio AND F.NIT=_nit_proveedor AND FD.DESCRIPCION='CAPITAL';
	
		select into _interes  coalesce(sum(FD.valor_UNITARIO),0)
		FROM CON.FOTO_CARTERA FC 
		INNER JOIN CON.FACTURA_DETALLE FD ON FC.DOCUMENTO=FD.DOCUMENTO
		WHERE  FC.NEGASOC=_negocio  AND FC.FECHA_VENCIMIENTO::DATE<=_fecha_corte::DATE AND FD.DESCRIPCION='INTERESES'
		AND  FC.VALOR_SALDO!=0  AND FC.PERIODO_LOTE=_periodo;
		
		raise notice '_saldo %',_saldo;
		raise notice '_interes %', _interes;
		
		if _saldo > 0 then
		
		_total=_saldo ;
		
		raise notice '_saldo>0 %',_total;
		
		else	
		
		_total=_interes;
		
		raise notice '_interes %',_total;
		
		end if;

			raise notice '_total %',_total;
		return _total;
					
END $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION fn_validar_saldo_cartera(character varying, character varying, character varying, date)
  OWNER TO postgres;

