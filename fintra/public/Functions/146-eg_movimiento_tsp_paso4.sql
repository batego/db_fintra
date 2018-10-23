-- Function: eg_movimiento_tsp_paso4(integer, character varying, character varying, character varying)

-- DROP FUNCTION eg_movimiento_tsp_paso4(integer, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION eg_movimiento_tsp_paso4(_filtro integer, _periodoi character varying, _periodof character varying, _tipoanticipo character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE
resultado RECORD;
_documentoRelacionado record;
_concept_code VARCHAR;
_arrCuentasATE varchar[] := '{13802701,13802702}';--debito
_arrCuentasAGA varchar[] := '{13802701,13802704}';--23050118 debito gac
_arrCuentasEXT varchar[] := '{1,22050401,1}';

_strTipoOperacion varchar:='Tipo operacion: ';
_strNumeroOperacion varchar:='Numero Operacion: ';
_strFinNumeroOperacion varchar:= '  Tipo Documento:';
_intPosTipoOperacion integer:=0;
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
		--filtro1:= ' AND b.fechadoc BETWEEN '''|| _dateStart ||'''::date AND ''' || _dateEnd || '''::date';
		filtro1:= ' AND b.periodo::INTEGER BETWEEN REPLACE(SUBSTRING('''||_dateStart||''',1,7),''-'','''') ::INTEGER AND REPLACE(SUBSTRING('''||_dateEnd||''',1,7),''-'','''')::INTEGER';

	ELSE
		filtro1:=' AND b.periodo  BETWEEN  '''||_periodoI||''' AND '''||_periodoF||'''  ';

	END IF;


	--validamos el paso 34 si es para AET  o AGA
	IF(_tipoanticipo='AET')THEN
		filtro2:=' AND a.cuenta in ('''||_arrCuentasATE[1]||''','''||_arrCuentasATE[2]||''') AND a.tipodoc in (''FAC'') ';
		_concept_code:='01';
	ELSIF(_tipoanticipo='AGA') THEN
		filtro2:=' AND  a.cuenta in ('''||_arrCuentasAGA[1]||''','''||_arrCuentasAGA[2]||''') AND  a.tipodoc in (''FAC'')';
	ELSIF(_tipoanticipo='EXT')THEN

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
		--SI EL DETALLE ES VACIO PONEMOS EL DEL COMPROBANTE
		IF(resultado.detalle is null)THEN
			resultado.detalle=resultado.detalle_comprobante;
		END IF;

		--RAISE NOTICE '_arrCuentasAGA : %',_arrCuentasAGA[2];
		IF(resultado.cuenta IN (_arrCuentasATE[2],_arrCuentasAGA[2]))THEN
			--RAISE NOTICE 'resultado.numdoc: % _arrCuentasAGA : % resultado.detalle: %',resultado.numdoc,_arrCuentasAGA[2],resultado.detalle;
			--tipo operacion
			_intPosTipoOperacion:=strpos(resultado.detalle,_strTipoOperacion)+length(_strTipoOperacion);
			resultado.tipodoc_rel:=SUBSTRING(resultado.detalle,_intPosTipoOperacion,3);
			--numero operacion.
			_intPosTipoOperacion:=strpos(resultado.detalle,_strNumeroOperacion)+length(_strNumeroOperacion);
			resultado.documento_rel:=SUBSTRING(resultado.detalle,_intPosTipoOperacion,(strpos(resultado.detalle,_strFinNumeroOperacion)-_intPosTipoOperacion));

		END IF;

		--Agregamos la planilla
		IF(strpos(resultado.documento_rel, '_')>0)THEN
		  resultado.tipo_referencia_1:='PLANILLA';
		  resultado.referencia_1:=SUBSTRING(resultado.numdoc,1,strpos(resultado.documento_rel, '_')-1);
		ELSE
		   resultado.tipo_referencia_1:='PLANILLA';
		   resultado.referencia_1:=resultado.documento_rel;
		END IF;

		--filtro de salida
		IF(resultado.tipodoc_rel IN (_tipoanticipo))THEN
			return NEXT resultado;
		END IF;

	END LOOP;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_movimiento_tsp_paso4(integer, character varying, character varying, character varying)
  OWNER TO postgres;
