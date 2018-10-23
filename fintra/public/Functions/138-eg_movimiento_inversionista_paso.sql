-- Function: eg_movimiento_inversionista_paso(integer, character varying, character varying, character varying)

-- DROP FUNCTION eg_movimiento_inversionista_paso(integer, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION eg_movimiento_inversionista_paso(_filtro integer, _periodoi character varying, _periodof character varying, _paso character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE
resultado RECORD;
_documentoRelacionado record;
_concept_code VARCHAR;
_arrCuentasPaso1 varchar[] := '{21959501}';
_arrCuentasPaso2 varchar[] := '{21959502,21959501}';
_arrCuentasPaso3 varchar[] := '{21959502}';
_arrCuentasPaso4 varchar[] := '{G010120065335,23680107,23653507,21959501}';

_iterador INTEGER:=1;

 _separatorDate VARCHAR:='-';
 _dateStart VARCHAR:=SUBSTRING(current_date,1,5)||'01'||_separatorDate||'01' ;
 _dateEnd VARCHAR:=SUBSTRING(current_date,1,5)||'12'||_separatorDate||'31' ;

sql text;
filtro1 VARCHAR;
filtro2 VARCHAR;



BEGIN

	--Filtros
	--1.)Año actual
	--2.)Año Anterior
	--3.)Ultimos Seis Meses
	--4.)Rango Periodos
	--5.)Ultimos 12 Meses
	--6.)Mes Pasado
	--7.)Mes Presente

	IF(_filtro=2)THEN
	   _dateStart:=_dateStart::DATE - '1 years'::interval;
	   _dateEnd:=_dateEnd::DATE - '1 years'::interval;
	ELSIF(_filtro=3)THEN
            _dateStart:=current_date- '6 Month'::interval;
	    _dateStart:=SUBSTRING(_dateStart,1,7)||_separatorDate||'01' ;
	    _dateEnd:=current_date;
	ELSIF(_filtro=5)THEN
	    _dateStart:=current_date- '12 Month'::interval;
	    _dateStart:=SUBSTRING(_dateStart,1,7)||_separatorDate||'01' ;
	    _dateEnd:=current_date;
	ELSIF(_filtro=6)THEN
	    _dateStart:=current_date- '1 Month'::interval;
	    _dateStart:=SUBSTRING(_dateStart,1,7)||_separatorDate||'01' ;
	    _dateEnd:=current_date;
	ELSIF(_filtro=7)THEN
	    _dateStart:=current_date;
	    _dateEnd:=current_date;
	END IF;

	IF (_filtro !=4)THEN

		filtro1:= ' AND b.periodo::INTEGER BETWEEN REPLACE(SUBSTRING('''||_dateStart||''',1,7),''-'','''') ::INTEGER AND REPLACE(SUBSTRING('''||_dateEnd||''',1,7),''-'','''')::INTEGER';

	ELSE
		filtro1:=' AND b.periodo  BETWEEN  '''||_periodoI||''' AND '''||_periodoF||'''  ';

	END IF;

	--validamos las cuentas de cada paso
       --filtro2:=' AND a.cuenta in ('''||_arrCuentasATE[1]||''','''||_arrCuentasATE[2]||''','''||_arrCuentasATE[3]||''')';
	IF(_paso='paso1')THEN
		filtro2:=' AND a.cuenta in ('''||_arrCuentasPaso1[1]||''') AND a.tipodoc=''ING''' ;
	ELSIF(_paso='paso2') THEN
		filtro2:=' AND a.cuenta in ('''||_arrCuentasPaso2[1]||''','''||_arrCuentasPaso2[2]||''') AND a.tipodoc=''FAP''';
	ELSIF(_paso='paso3')THEN
		filtro2:=' AND a.cuenta in ('''||_arrCuentasPaso3[1]||''') AND a.tipodoc in(''FAP'',''EGR'') ';
	ELSIF(_paso='paso4')THEN
		filtro2:=' AND a.cuenta in ('''||_arrCuentasPaso4[1]||''','''||_arrCuentasPaso4[2]||''','''||_arrCuentasPaso4[3]||''','''||_arrCuentasPaso4[4]||''')
			   AND a.tipodoc=''CDIAR''
			  AND ((a.detalle in (''INTERESES O RENDI/FINANCIEROS'',''RICA 5*1000'')  AND valor_credito >0
				OR (SUBSTRING(a.detalle,1,18)=''COMPROBANTE CIERRE'') AND valor_credito >0)
				OR (a.detalle in (''Intereses'') AND valor_debito >0 ))';

	ELSIF(_paso='paso5')THEN
		filtro2:=' AND a.cuenta in ('''||_arrCuentasPaso4[1]||''','''||_arrCuentasPaso4[2]||''','''||_arrCuentasPaso4[3]||''','''||_arrCuentasPaso4[4]||''')
			   AND a.tipodoc=''CDIAR''
			  AND (a.detalle not in (''Intereses'',''INTERESES O RENDI/FINANCIEROS'',''RICA 5*1000'')
				OR (SUBSTRING(a.detalle,1,18) !=''COMPROBANTE CIERRE''))';
	END IF;


	---se añade la bd de la empresa para añadir el numos linea: 82
	sql:='SELECT  a.dstrct::varchar
			,a.cuenta::varchar
			,a.auxiliar::varchar
			,a.periodo::varchar
			,b.fechadoc::varchar
			,a.tipodoc::varchar
			,coalesce(UPPER(c.descripcion), a.tipodoc ) as tipodoc_desc
			,a.numdoc::varchar
			,CASE WHEN b.tipodoc = ''NEG'' THEN  b.numdoc
				WHEN b.tipodoc = ''EGR'' THEN (SELECT  cxp.descripcion FROM fin.cxp_doc as cxp where tipo_documento = ''FAP'' and dstrct = ''FINV'' and cxp.cheque=a.numdoc and clase_documento_rel=''NEG'' and proveedor = a.tercero limit 1)
				WHEN b.tipodoc = ''FAP'' THEN (SELECT cxp1.descripcion FROM fin.cxp_doc as cxp1  where documento=a.numdoc and tipo_documento =''FAP'' and dstrct = ''FINV'' and proveedor = a.tercero limit 1 )
				WHEN b.tipodoc = ''NC''  THEN (SELECT cxp2.descripcion FROM fin.cxp_doc as cxp2 WHERE dstrct = ''FINV'' and cxp2.documento=(SELECT cxp3.documento_relacionado FROM fin.cxp_doc as cxp3
									      WHERE dstrct = ''FINV'' and tipo_documento =''NC'' and documento=a.numdoc and proveedor = a.tercero limit 1)
								    and cxp2.periodo=a.periodo limit 1)

				WHEN b.tipodoc = ''ND''  THEN (SELECT cxp2.descripcion FROM fin.cxp_doc as cxp2 WHERE dstrct = ''FINV'' and cxp2.documento=(SELECT cxp3.documento_relacionado FROM fin.cxp_doc as cxp3
									      WHERE dstrct = ''FINV'' and tipo_documento =''ND'' and documento=a.numdoc and proveedor = a.tercero limit 1)
								    and cxp2.periodo=a.periodo limit 1)

				WHEN b.tipodoc = ''FAC'' THEN (select descripcion from con.factura where documento = b.numdoc)
				WHEN b.tipodoc = ''ING'' THEN (select descripcion from con.ingreso_detalle where num_ingreso = b.numdoc and factura = a.documento_rel limit 1)
				WHEN b.tipodoc = ''ICA'' THEN (select descripcion from con.factura where documento = (select documento from con.ingreso_detalle where num_ingreso = b.numdoc and item = 1))
				WHEN b.tipodoc = ''CDIAR'' THEN a.detalle
			END as detalle
			,a.detalle::varchar as detalle_comprobante
			,a.abc::varchar
			,a.valor_debito::numeric
			,a.valor_credito::numeric
			,a.tercero::varchar
			,CASE WHEN a.tercero != '''' THEN get_nombrenit(a.tercero) ELSE '''' END as nombre_tercero
			,a.tipodoc_rel::varchar
			,a.documento_rel
			,a.vlr_for::numeric
			,b.moneda_foranea::varchar
			,''''::varchar as tipo_referencia_1
			,''''::varchar as referencia_1
			,''''::varchar as tipo_referencia_2
			,a.referencia_2
			,a.tipo_referencia_3
			,a.tipo_referencia_3
			,a.referencia_3
			,''''::varchar as documento_rel2
	        FROM con.comprodet a
	        INNER JOIN con.comprobante b ON (b.tipodoc = a.tipodoc AND b.numdoc = a.numdoc AND b.grupo_transaccion = a.grupo_transaccion)
		LEFT  JOIN con.tipo_docto  c ON (c.codigo  = a.tipodoc)
		WHERE a.dstrct = ''FINV''
		      '||filtro1||filtro2||'
		      AND a.reg_status = ''''
		ORDER BY
	              a.documento_rel,
		      a.cuenta,
		      a.numdoc';

	raise notice 'sql: %',sql;


	FOR resultado in
		EXECUTE	sql
	LOOP
		RAISE NOTICE 'Procesando registro numero:= %',_iterador;
		_iterador=_iterador+1;

		return NEXT resultado;

	END LOOP;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_movimiento_inversionista_paso(integer, character varying, character varying, character varying)
  OWNER TO postgres;
