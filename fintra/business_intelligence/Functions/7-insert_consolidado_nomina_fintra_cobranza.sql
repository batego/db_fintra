-- Function: business_intelligence.insert_consolidado_nomina_fintra_cobranza()

-- DROP FUNCTION business_intelligence.insert_consolidado_nomina_fintra_cobranza();

CREATE OR REPLACE FUNCTION business_intelligence.insert_consolidado_nomina_fintra_cobranza()
  RETURNS character varying AS
$BODY$
DECLARE


 _periodo varchar:= replace(substring(now(),1,7),'-','');


BEGIN
        raise notice '_periodo %',_periodo;


	raise notice 'Paso 1';

	DELETE FROM business_intelligence.consolidado_nomina_fintra_cobranza WHERE periodo =_periodo;
	INSERT INTO business_intelligence.consolidado_nomina_fintra_cobranza(dstrct, anio, periodo, cuenta, tipo_documento, detalle, clasificacion, nit_empleado, nombre_empleado, valor_debito, valor_credito, empresa)
	SELECT
	       'FINV' as dstrct,
	       substring(periodo, 1,4) as anio,
	       periodo,
	       cdet.cuenta,
	       cdet.tipodoc as tipo_documento,
	       cdet.detalle,
	       cdina.clasificacion,
	       tercero as nit_empleado,
	       get_nombp(tercero) as nombre_empleado,
	       sum(valor_debito) as valor_debito,
	       sum(valor_credito)as valor_credito,
	       'FINTRA' as empresa
	FROM con.comprodet cdet
	INNER JOIN con.configuracion_cuentas_dinamica_contable cdina on (cdina.cuenta=cdet.cuenta)
	WHERE  cdina.modulo='BINOMINA'
	and periodo = _periodo
	and cdet.dstrct='FINV'
	and cdet.reg_status=''
	group by periodo,cdet.cuenta,tercero,cdina.clasificacion,cdet.tipodoc,cdet.detalle
	order by
	periodo,
	get_nombp(tercero),
	cdet.cuenta;

	raise notice 'Paso 2';

	INSERT INTO business_intelligence.consolidado_nomina_fintra_cobranza(dstrct, anio, periodo, cuenta, tipo_documento, detalle, clasificacion, nit_empleado, nombre_empleado, valor_debito, valor_credito, empresa)
	SELECT
		dstrct,
		anio,
		periodo,
		cuenta,
		tipo_documento,
		detalle,
		clasificacion,
		nit_empleado,
		nombre_empleado,
		valor_debito,
		valor_credito,
		'COBRANZA'::TEXT as empresa
	FROM dblink('dbname=cobranza
		port=5432
		host=localhost
		user=postgres
		password=bdversion17'::text,
	'SELECT
		''FINV'' as dstrct,
		substring(periodo, 1,4) as anio,
		periodo,
	       cdet.cuenta,
	       cdet.tipodoc as tipo_documento,
	       cdet.detalle,
	       cdina.clasificacion,
	       tercero as nit_empleado,
	       get_nombp(tercero) as nombre_empleado,
	       sum(valor_debito) as valor_debito,
	       sum(valor_credito)as valor_credito
       FROM con.comprodet cdet
	INNER JOIN con.configuracion_cuentas_dinamica_contable cdina on (cdina.cuenta=cdet.cuenta)
	WHERE  cdina.modulo=''BINOMINA''
	and periodo = '''||_periodo||'''
	and cdet.dstrct=''FINV''
	and cdet.reg_status=''''
	group by periodo,cdet.cuenta,tercero,cdina.clasificacion,cdet.tipodoc,cdet.detalle
	order by
	periodo,
	get_nombp(tercero),
	cdet.cuenta'::text) tabla(
		dstrct character varying,
		anio character varying,
		periodo character varying,
		cuenta character varying,
		tipo_documento character varying,
		detalle character varying,
		clasificacion  character varying,
		nit_empleado character varying,
		nombre_empleado  character varying,
		valor_debito numeric,
		valor_credito numeric);

	ANALYZE business_intelligence.consolidado_nomina_fintra_cobranza;


	RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION business_intelligence.insert_consolidado_nomina_fintra_cobranza()
  OWNER TO postgres;
