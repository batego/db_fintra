-- Function: reporte_cartera(text, text)

-- DROP FUNCTION reporte_cartera(text, text);

CREATE OR REPLACE FUNCTION reporte_cartera(_periodo text, _cuenta text)
  RETURNS SETOF returntype AS
$BODY$ DECLARE
  r returntype%rowtype;
  _group record;
--drop type returntype
/*SE CREO EL rowtype
create type returntype as
(	a text,
	b text,
	c text,
	d text,
	e text,
	f text
);*/
BEGIN
	for _group IN select a,b,c,d,e,f
		from(
		(SELECT 2 as tpe,'TIPO DOCUMENTO' as a,'DOCUMENTO' as b,'NIT' as c,'FECHA CONTABLE' as d, 'VALOR DEBITO' as e, 'VALOR CREDITO' as f)
		UNION ALL
		(SELECT 1 as tpe,'DOCUMENTO','NIT','FECHA FACTURA','FECHA VENCIMIENTO', 'VALOR FACTURA', 'FECHA DE ENTREGA FIDUCIA')
		UNION ALL
		select tpe,documento,nit,fecha_factura,fecha_vencimiento,valor_factura,creation_date
		from
		((SELECT	1 as tpe,cd.cuenta,SUBSTRING(REPLACE(f.creation_date,'-',''),1,6) as periodo,f.documento,f.nit,f.fecha_factura::date::text,f.fecha_vencimiento::date::text,f.valor_factura::text,f.creation_date::date::text
		FROM
			con.factura f,
			cliente,
			con.comprodet cd
		WHERE
			(documento like 'PC%' or documento like 'PL%' or documento like 'PG%')
			AND cliente.codcli = f.codcli
			AND f.reg_status =''
			AND cd.grupo_transaccion=f.transaccion and  f.nit not in (SELECT DATO FROM TABLAGEN WHERE TABLE_TYPE ='CED_EXC')
		ORDER BY
			f.creation_date, f.negasoc, f.documento)
		UNION ALL
		(	SELECT 2 as tpe,c.cuenta,SUBSTRING(REPLACE(f.creation_date,'-',''),1,6),c.tipodoc,c.numdoc,c.tercero,c.creation_date::date::text,c.valor_debito::TEXT,c.valor_credito::TEXT
			FROM	con.comprodet c,(  SELECT  distinct negasoc, substring(creation_date,1,10) as creation_date,codcli as xc
						   FROM con.factura
						   WHERE (documento LIKE 'PC%' OR documento LIKE 'PL%' or documento like 'PG%') AND reg_status!='A' and  nit not in (SELECT DATO FROM TABLAGEN WHERE TABLE_TYPE ='CED_EXC')
						   ORDER BY negasoc) f
			WHERE	numdoc = f.negasoc
		)) as foo
		where periodo=_periodo AND cuenta=_cuenta) as foo
		where CASE WHEN _cuenta IN ('27050503', 'I010010014209','I010010014210') THEN 2 ELSE 1 END=tpe LOOP
	    r.a := _group.a;
	    r.b := _group.b;
	    r.c := _group.c;
	    r.d := _group.d;
	    r.e := _group.e;
	    r.f := _group.f;
	    return next r;
	END LOOP;
RETURN ;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION reporte_cartera(text, text)
  OWNER TO postgres;
