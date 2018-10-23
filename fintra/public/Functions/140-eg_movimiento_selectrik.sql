-- Function: eg_movimiento_selectrik(character varying, character varying, character varying, character varying)

-- DROP FUNCTION eg_movimiento_selectrik(character varying, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION eg_movimiento_selectrik(_periodoi character varying, _periodof character varying, _paso character varying, _lineanegocio character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE
resultado RECORD;
_documentoRelacionado record;
_concept_code VARCHAR;
_arrCuentasPaso2 varchar[] := '{}';
_arrCuentasPaso3 varchar[] := '{}';
_arrCuentasPaso4 varchar[] := '{}';

_iterador INTEGER:=1;


sql text;
filtro1 VARCHAR;
filtro2 VARCHAR;
_tipodoc VARCHAR;


BEGIN

	raise notice '_tipodoc : % _periodof % ',_tipodoc,_periodof;

	--filtro
	filtro1:='AND b.periodo  BETWEEN  '''||_periodoI||''' AND '''||_periodoF||'''  ';
       -- filtro2:='AND a.tipodoc in ('||_tipodoc||')' ;



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
			,a.documento_rel::varchar(200)
			,a.vlr_for::numeric
			,b.moneda_foranea::varchar
			,tipo_referencia_1::varchar
			,referencia_1::varchar
			,tipo_referencia_2::varchar
			,a.referencia_2::varchar
			,a.tipo_referencia_3::varchar
			,a.tipo_referencia_3::varchar
			,a.referencia_3::varchar
			,''''::varchar as documento_rel2
			,conf.tipo_documento::varchar as tipo_convenio
			,conf.clasificacion::varchar as clasificacion_cuenta
	        FROM con.comprodet a
	        INNER JOIN con.comprobante b ON (b.tipodoc = a.tipodoc AND b.numdoc = a.numdoc AND b.grupo_transaccion = a.grupo_transaccion)
	        INNER JOIN con.configuracion_cuentas_dinamica_contable conf ON (conf.cuenta= a.cuenta)
		LEFT  JOIN con.tipo_docto  c ON (c.codigo  = a.tipodoc)
		WHERE a.dstrct = ''FINV''
		      AND modulo=''CONTROL_OPERACIONES_SELECTRIK''
		      AND conf.paso='''||_paso||''' AND conf.reg_status=''''
		      AND conf.visualizar =''S''
		      '||filtro1||'
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

		IF(resultado.tipodoc='FAC')THEN
			IF(resultado.numdoc like 'R0%' AND resultado.detalle Ilike 'CUOTAS INICIALES%')THEN
			    resultado.tipodoc_rel :='MS';
			    resultado.documento_rel :=substring(resultado.detalle from position('FOMS' in resultado.detalle) for 12);
			ELSE
			    resultado.tipodoc_rel :='MS';
			    resultado.documento_rel :=(SELECT ref1 FROM con.factura  where documento =resultado.numdoc);
			END IF;

			  resultado.tipo_referencia_1:='FCHA';
			  resultado.referencia_1:=(select fecha_vencimiento from con.factura where documento = resultado.numdoc);
			  resultado.documento_rel2:=replace(substring(resultado.referencia_1,1,7),'-','');
		END IF;

		IF(resultado.tipodoc IN ('ICA','ICR') AND resultado.tipodoc_rel='FAC')THEN
			resultado.tipodoc_rel :='MS';
			resultado.documento_rel :=(SELECT ref1 FROM con.factura  where documento =resultado.documento_rel);

		END IF;

		IF(resultado.tipodoc IN ('ICA','ICR') AND resultado.tipodoc_rel='')THEN
			resultado.tipodoc_rel :='MS';
			raise notice 'resultado.numdoc : %',resultado.numdoc;
			--resultado.documento_rel :='';

			FOR _documentoRelacionado IN
					(SELECT (SELECT ref1 FROM con.factura  where documento =indet.documento) as documento
						    FROM con.ingreso_detalle indet  where num_ingreso =resultado.numdoc and documento !=''
						   GROUP BY (SELECT ref1 FROM con.factura  where documento =indet.documento)  )
		        LOOP
			     raise notice '_documentoRelacionado.documento : %',_documentoRelacionado.documento;
			     resultado.documento_rel :=resultado.documento_rel||''||_documentoRelacionado.documento||' ';
			END LOOP;

		END IF;

		IF(resultado.tipodoc='CDIAR' AND resultado.tipodoc_rel='' )THEN
			IF(POSITION('FOMS' in resultado.detalle) > 0)THEN
				resultado.tipodoc_rel :='MS';
				raise notice 'position(''FOMS'' in resultado.detalle) : %',position('FOMS' in resultado.detalle);
				resultado.documento_rel :=substring(resultado.detalle from position('FOMS' in resultado.detalle) for 12);
			END IF;
		END IF;

		IF(resultado.tipodoc='CDIAR' AND resultado.tipodoc_rel='FAC' )THEN
			resultado.tipodoc_rel :='MS';
			resultado.documento_rel :=(SELECT ref1 FROM con.factura  where documento =resultado.documento_rel);
		END IF;

		return NEXT resultado;

	END LOOP;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_movimiento_selectrik(character varying, character varying, character varying, character varying)
  OWNER TO postgres;
