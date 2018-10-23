-- Function: eg_movimiento_fintracredit_paso(character varying, character varying, character varying, character varying)

-- DROP FUNCTION eg_movimiento_fintracredit_paso(character varying, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION eg_movimiento_fintracredit_paso(_periodoi character varying, _periodof character varying, _paso character varying, _lineanegocio character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE
resultado RECORD;
_documentoRelacionado record;
_concept_code VARCHAR;

_iterador INTEGER:=1;


sql text;
filtro1 VARCHAR;
filtro2 VARCHAR;
_tipodoc VARCHAR;


BEGIN


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
			,a.documento_rel
			,a.vlr_for::numeric
			,b.moneda_foranea::varchar
			,''''::varchar as tipo_referencia_1
			,''''::varchar as referencia_1
			,a.tipo_referencia_2
			,a.referencia_2
			,a.tipo_referencia_3
			,a.tipo_referencia_3
			,a.referencia_3
			,''''::varchar as documento_rel2
			,conf.tipo_documento::varchar as tipo_convenio
			,conf.clasificacion::varchar
			,''''::varchar as agencia
			,''''::varchar as periodo_desembolso
	        FROM con.comprodet a
	        INNER JOIN con.comprobante b ON (b.tipodoc = a.tipodoc AND b.numdoc = a.numdoc AND b.grupo_transaccion = a.grupo_transaccion)
	        INNER JOIN con.configuracion_cuentas_dinamica_contable conf ON (conf.cuenta= a.cuenta)
		LEFT  JOIN con.tipo_docto  c ON (c.codigo  = a.tipodoc)
		WHERE a.dstrct = ''FINV''
		      AND modulo=''CONTROL_OPERACIONES''
		      AND conf.paso='''||_paso||''' AND conf.reg_status=''''
		      AND conf.visualizar =''S''
		      AND conf.tipo_documento='''||_lineaNegocio||'''
		      '||filtro1||'
		      AND a.reg_status = ''''
		     -- AND a.numdoc=''FZD00002''
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


		--Cartera
		IF(resultado.tipodoc='FAC')THEN
			  resultado.tipodoc_rel:='NEG';
			  resultado.documento_rel:=(select negasoc from con.factura where documento = resultado.numdoc GROUP BY negasoc);
			  resultado.tipo_referencia_1:='FCHA';
			  resultado.referencia_1:=(select fecha_vencimiento from con.factura where documento = resultado.numdoc);
		END IF;

		--Cartera
		IF(resultado.tipodoc !='FAC' AND resultado.tipodoc_rel='FAC')THEN
			  resultado.tipodoc_rel:='NEG';
			  resultado.documento_rel:=(select negasoc from con.factura where documento = resultado.documento_rel GROUP BY negasoc);
			  resultado.tipo_referencia_1:='FCHA';
			  resultado.referencia_1:=(select fecha_vencimiento from con.factura where documento = resultado.documento_rel );
		END IF;

		IF(resultado.tipodoc='FAP')THEN
		        resultado.tipodoc_rel:='NEG';
			resultado.documento_rel:=(SELECT documento_relacionado FROM fin.cxp_doc  where documento=resultado.numdoc and  tipo_documento=resultado.tipodoc and reg_status='' and dstrct='FINV' );
			--validacion de las fianzas
			raise notice 'resultado.numdoc : %',resultado.numdoc;
			IF(resultado.documento_rel='' and resultado.numdoc like 'FZ%' )THEN
				resultado.tipodoc_rel:=resultado.tipo_referencia_2;
				resultado.documento_rel:=resultado.referencia_2;
				resultado.agencia:=(SELECT agencia FROM administrativo.historico_deducciones_fianza  where documento_cxp=resultado.numdoc group by agencia);
			END IF;

		END IF;

		IF(resultado.tipodoc='NC' AND resultado.referencia_2 !='')THEN
			 resultado.tipodoc_rel:='NEG';
			 resultado.documento_rel:=resultado.referencia_2;

		END IF;


		--FENALCO ATLANTICO
		IF(resultado.tipo_convenio IN ('FA') AND resultado.numdoc like 'CM%' AND resultado.tipodoc !='CM'  )THEN
			resultado.tipo_convenio:='CAFA';
			resultado.tipodoc_rel:='NEG';
			resultado.documento_rel:=(select negasoc from con.factura where documento = resultado.numdoc GROUP BY negasoc);
			IF(resultado.documento_rel ILIKE 'FB%')THEN
			     resultado.tipo_convenio:='CAFB';
			END IF;
		END IF;


		--FENALCO BOLIVAR
		IF(resultado.tipo_convenio IN ('FB') AND resultado.numdoc like 'CM%'  AND resultado.tipodoc !='CM')THEN
			resultado.tipo_convenio:='CAFB';
			resultado.tipodoc_rel:='NEG';
			resultado.documento_rel:=(select negasoc from con.factura where documento = resultado.numdoc GROUP BY negasoc);
			IF(resultado.documento_rel ILIKE 'FA%')THEN
			     resultado.tipo_convenio:='CAFA';
			END IF;
		END IF;


		--validamos cuentas conpartidas
		IF(resultado.tipo_convenio IN ('FA') AND resultado.cuenta  in ('16252141','16252102')and resultado.documento_rel Ilike 'FB%' )THEN
			resultado.tipo_convenio:='FB';
		END IF;

		IF(resultado.tipo_convenio IN ('FB') AND resultado.cuenta  in ('16252141','16252102')and resultado.documento_rel Ilike 'FA%' )THEN
			resultado.tipo_convenio:='FA';
		END IF;


		--validamos el egreso
		IF(EXISTS(SELECT SUBSTRING(cheque,1,2),SUBSTRING(documento_relacionado,1,2) FROM fin.cxp_doc  WHERE cheque ILIKE 'EG%' AND SUBSTRING(documento_relacionado,1,2) !='' AND cheque=resultado.numdoc
				AND SUBSTRING(documento_relacionado,1,2)=resultado.tipo_convenio group by SUBSTRING(cheque,1,2),SUBSTRING(documento_relacionado,1,2)))THEN

			resultado.tipodoc_rel:='NEG';
			resultado.documento_rel:=(SELECT documento_relacionado FROM fin.cxp_doc WHERE cheque=resultado.numdoc and reg_status='');

		ELSIF(resultado.tipodoc ='EGR')THEN
			CONTINUE ;
		END IF;

		--buscamos la agencia del negocio segun el documento relacionado.
		IF(resultado.tipodoc_rel='NEG')THEN
			resultado.agencia:=(SELECT c.agencia FROM negocios neg INNER JOIN convenios c on (neg.id_convenio=c.id_convenio)  WHERE cod_neg=resultado.documento_rel);
			resultado.periodo_desembolso:=(select replace(substring(f_desem,1,7),'-','') from negocios where cod_neg=resultado.documento_rel);
		END IF;




		return NEXT resultado;

	END LOOP ;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_movimiento_fintracredit_paso(character varying, character varying, character varying, character varying)
  OWNER TO postgres;
