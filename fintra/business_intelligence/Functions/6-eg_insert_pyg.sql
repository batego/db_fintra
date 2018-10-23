-- Function: business_intelligence.eg_insert_pyg(character varying)

-- DROP FUNCTION business_intelligence.eg_insert_pyg(character varying);

CREATE OR REPLACE FUNCTION business_intelligence.eg_insert_pyg(_periodo character varying)
  RETURNS text AS
$BODY$
DECLARE
  result text := 'OK';
 -- _periodo text :=replace(substring(now(),1,7),'-','');
 BEGIN

    raise info '_periodo : %',_periodo;

	--1.)Borra periodo actual para insertarlo nuevamente.
	DELETE FROM business_intelligence.consolidado_pyg_fintra where periodo=_periodo;

	--2.)Insertamos la nueva data
	INSERT INTO business_intelligence.consolidado_pyg_fintra (anio, periodo, tipo, cuenta, centro_costo, nombre_cuenta,
            tercero, nombre_tercero, tipodoc, numdoc, detalle, tipodoc_rel,
            documento_rel, valor_debito, valor_credito, diferencia)
	SELECT
		substring(cdet.periodo,1,4) as anio
		,cdet.periodo
		,CASE WHEN SUBSTRING(cdet.cuenta,1,1) IN ('I','C','G') THEN substring (cdet.cuenta,1,1)
		      WHEN cdet.cuenta IN ('16252150','16252151','16252153') THEN 'C'
		      WHEN cdet.cuenta IN ('16252156','16252155','16252080') THEN 'G'
		      WHEN cdet.cuenta IN ('16252141','16252144','16252092','16252142','16252148','16252149','16252145') THEN 'I'
		  END AS tipo
		,cdet.cuenta
		,substring (cdet.cuenta,1,9) as centro_costo
		,cta.nombre_largo as nombre_cuenta
		,cdet.tercero
		,get_nombp(cdet.tercero) as nombre_tercero
		,cdet.tipodoc
		,cdet.numdoc
		,cdet.detalle
		,cdet.tipodoc_rel
		,cdet.documento_rel
		,sum(cdet.valor_debito) as valor_debito
		,sum(cdet.valor_credito)as valor_credito,
		case when substring (cdet.cuenta,1,1) ='I' OR  cdet.cuenta IN ('16252141','16252144','16252092','16252142','16252148','16252149','16252145') then
		   sum(cdet.valor_credito)-sum(cdet.valor_debito)
		else
		   sum(cdet.valor_debito)-sum(cdet.valor_credito)
		end as diferencia
	    FROM con.comprodet cdet
	    INNER JOIN  con.comprobante c on (cdet.numdoc=c.numdoc and cdet.grupo_transaccion=c.grupo_transaccion)
	    INNER JOIN con.cuentas cta on (cta.cuenta=cdet.cuenta)
	    WHERE cdet.periodo between _periodo and _periodo and cdet.reg_status='' and cdet.dstrct='FINV'
	    AND (substring(cdet.cuenta,1,1) in ('I','C','G') or cdet.cuenta in ('16252150','16252151','16252153',
										'16252156','16252155','16252080',
										'16252141','16252144','16252092','16252142','16252148','16252149','16252145'))
	    GROUP BY
	    cdet.periodo,
	    cdet.cuenta,
	    cta.nombre_largo,
	    cdet.tercero,
	    cdet.tipodoc,
	    cdet.numdoc,
	    cdet.detalle,
	    cdet.tipodoc_rel,
	    cdet.documento_rel
	    ORDER BY
	    substring(cdet.periodo,1,4)
	    ,cdet.periodo,substring(cdet.cuenta,1,1)
	    ,cdet.tipodoc;

	ANALYZE business_intelligence.consolidado_pyg_fintra;

RETURN result;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION business_intelligence.eg_insert_pyg(character varying)
  OWNER TO postgres;
