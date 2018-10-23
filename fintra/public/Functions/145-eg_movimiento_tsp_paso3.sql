-- Function: eg_movimiento_tsp_paso3(integer, character varying, character varying, character varying)

-- DROP FUNCTION eg_movimiento_tsp_paso3(integer, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION eg_movimiento_tsp_paso3(_filtro integer, _periodoi character varying, _periodof character varying, _tipoanticipo character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE
resultado RECORD;
_documentoRelacionado record;
_concept_code VARCHAR;
_arrCuentasATE varchar[] := '{I010030024208,22050401,11100103,11200501}';
_arrCuentasAGA varchar[] := '{22050403,23050118}';
_arrCuentasEXT varchar[] := '{22050301,I010020024208,11100103,11200501}';
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


	--validamos el paso 3 si es para AET  o AGA
	IF(_tipoanticipo='AET')THEN
		filtro2:=' AND a.cuenta in ('''||_arrCuentasATE[1]||''','''||_arrCuentasATE[2]||''','''||_arrCuentasATE[3]||''','''||_arrCuentasATE[4]||''')';
		_concept_code:='01';
	ELSIF(_tipoanticipo='AGA') THEN
		filtro2:=' AND  a.cuenta in ('''||_arrCuentasAGA[1]||''','''||_arrCuentasAGA[2]||''')';
		_concept_code:='10';
	ELSIF(_tipoanticipo='EXT')THEN
		filtro2:=' AND a.cuenta in ('''||_arrCuentasEXT[1]||''','''||_arrCuentasEXT[2]||''','''||_arrCuentasEXT[3]||''','''||_arrCuentasEXT[4]||''')';
		_concept_code:='50';
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
		      AND a.tipodoc in (''EGR'')
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

		--BUSCAMOS EL DOCUMENTO RELACIONADO DE LA CUENTA DE BANCO
		IF(resultado.tipodoc_rel='')THEN

		    SELECT INTO _documentoRelacionado tipodoc_rel, documento_rel FROM con.comprodet
		    WHERE  numdoc=resultado.numdoc AND numdoc !=documento_rel AND reg_status=''
		    GROUP BY tipodoc_rel,documento_rel;

			resultado.tipodoc_rel:=_documentoRelacionado.tipodoc_rel;
			resultado.documento_rel:=_documentoRelacionado.documento_rel;

		END IF;

		--BUSCAMOS LA PLANILLA DEL COMPROBANTE

		IF(strpos(resultado.documento_rel, '_')>0)THEN

			resultado.tipo_referencia_1:='PLANILLA';
			resultado.referencia_1:=SUBSTRING(resultado.documento_rel,1,strpos(resultado.documento_rel, '_')-1);

		ELSIF(resultado.cuenta=_arrCuentasATE[3] AND SUBSTRING(resultado.numdoc,1,2)!='TR')THEN --VALIDAMOS EL BANCO
			resultado.tipo_referencia_1:=resultado.tipodoc_rel;
			resultado.referencia_1:=resultado.documento_rel;
		ELSE
			resultado.tipo_referencia_1:='PLANILLA';
			resultado.referencia_1:=resultado.documento_rel;
		END IF;

		IF(_concept_code='50')THEN
			SELECT INTO _documentoRelacionado tipo_operacion,concept_code FROM fin.anticipos_pagos_terceros  where planilla=resultado.referencia_1 and reg_status='' and  concept_code=_concept_code ;

			IF(_documentoRelacionado IS NULL AND resultado.referencia_1 LIKE 'E%')THEN
				SELECT INTO _documentoRelacionado 'EXT'::VARCHAR AS  tipo_operacion, _concept_code AS concept_code ;
				RAISE NOTICE 'entro 2 %',_documentoRelacionado;
			END IF;

		ELSE
			SELECT INTO _documentoRelacionado tipo_operacion,concept_code FROM fin.anticipos_pagos_terceros  where planilla=resultado.referencia_1 and reg_status='' and  concept_code=_concept_code ;
		END IF;

		resultado.tipo_referencia_2:=_documentoRelacionado.tipo_operacion;
		resultado.referencia_2:=_documentoRelacionado.concept_code;


		return NEXT resultado;

	END LOOP;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_movimiento_tsp_paso3(integer, character varying, character varying, character varying)
  OWNER TO postgres;
