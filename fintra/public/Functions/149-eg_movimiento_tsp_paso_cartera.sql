-- Function: eg_movimiento_tsp_paso_cartera(integer, character varying, character varying, character varying)

-- DROP FUNCTION eg_movimiento_tsp_paso_cartera(integer, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION eg_movimiento_tsp_paso_cartera(_filtro integer, _periodoi character varying, _periodof character varying, _tipoanticipo character varying)
  RETURNS SETOF record AS
$BODY$

DECLARE
resultado RECORD;
_documentoRelacionado record;
_concept_code VARCHAR;

_iterador INTEGER:=1;

 _separatorDate VARCHAR:='-';
 _dateStart VARCHAR:=SUBSTRING(current_date,1,5)||'01'||_separatorDate||'01' ;
 _dateEnd VARCHAR:=SUBSTRING(current_date,1,5)||'12'||_separatorDate||'31' ;

 _strTipoOperacion varchar:='Tipo operacion: ';
_strNumeroOperacion varchar:='Numero Operacion: ';
_strFinNumeroOperacion varchar:= '  Tipo Documento:';
_intPosTipoOperacion integer:=0;
_recordFactura record;

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
        --filtro1:= ' AND b.fechadoc BETWEEN '''|| _dateStart ||'''::date AND ''' || _dateEnd || '''::date';
        filtro1:= ' AND a.periodo::INTEGER BETWEEN REPLACE(SUBSTRING('''||_dateStart||''',1,7),''-'','''') ::INTEGER AND REPLACE(SUBSTRING('''||_dateEnd||''',1,7),''-'','''')::INTEGER';

    ELSE
        filtro1:=' AND a.periodo  BETWEEN  '''||_periodoI||''' AND '''||_periodoF||'''  ';

    END IF;

   IF( _tipoanticipo='AGA')THEN

	DELETE FROM tem.egresos_gasolina_banco;

	INSERT INTO tem.egresos_gasolina_banco
		SELECT cxp.periodo
		       ,cxp.cheque
		       ,cxp.documento
		       ,cxp.tipo_documento
		       ,cxp.corrida
		       ,egre.transaccion
		       ,coalesce((select periodo from con.comprodet  where grupo_transaccion=egre.transaccion group by periodo),'') as periodo_egreso
		FROM fin.cxp_doc cxp
		INNER JOIN egresodet egre on (egre.branch_code=cxp.banco  and egre.bank_account_no=cxp.sucursal and egre.document_no=cxp.cheque and egre.documento=cxp.documento and egre.tipo_documento=cxp.tipo_documento)
		WHERE cxp.handle_code='GA' AND cxp.dstrct ='FINV' AND cxp.reg_status='' AND cxp.tipo_documento='FAP';

	ANALYZE tem.egresos_gasolina_banco  ;



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
	    ,conf.tipo_documento::varchar as tipo_convenio
	    ,conf.clasificacion::varchar
	    ,conf.paso::varchar
	    ,a.grupo_transaccion::integer as fk_repo_prod
	    ,0::integer as dias_vencimiento
	    ,-1::numeric as valor_saldo
	    ,''''::varchar as dias_mora
            ,''''::varchar as numero_ingreso
            ,''''::varchar as periodo_ingreso
	FROM con.comprodet a
	INNER JOIN con.comprobante b ON (b.tipodoc = a.tipodoc AND b.numdoc = a.numdoc AND b.grupo_transaccion = a.grupo_transaccion)
	INNER JOIN con.configuracion_cuentas_dinamica_contable conf ON (conf.cuenta= a.cuenta)
	LEFT  JOIN con.tipo_docto  c ON (c.codigo  = a.tipodoc)
        WHERE a.dstrct = ''FINV''
              AND a.reg_status = ''''
	      AND modulo=''FINTRA_LOGISTICA''
	      AND conf.reg_status=''''
	      AND conf.visualizar =''S''
              '||filtro1||'
              AND conf.tipo_documento='''||_tipoanticipo||'''
              AND a.cuenta = ANY((SELECT ARRAY(SELECT CUENTA::VARCHAR FROM CON.CONFIGURACION_CUENTAS_DINAMICA_CONTABLE
					WHERE  MODULO=''FINTRA_LOGISTICA'' AND TIPO_DOCUMENTO='''||_tipoanticipo||'''))::character varying[])
	   --  AND a.numdoc in (''PP02097357'')
	    ORDER BY
                  a.documento_rel,
              a.cuenta,
              a.numdoc';

    raise notice 'sql: %',sql;


    FOR resultado in
        EXECUTE    sql
    LOOP
        RAISE NOTICE 'Procesando registro numero:= % resultado.numdoc : %',_iterador,resultado.numdoc ;
        _iterador=_iterador+1;
        --SI EL DETALLE ES VACIO PONEMOS EL DEL COMPROBANTE
		IF(resultado.detalle is null)THEN
		    resultado.detalle=resultado.detalle_comprobante;
		END IF;

		IF(resultado.tipo_convenio='AET')THEN
			_concept_code:='01';
		ELSIF(resultado.tipo_convenio='AGA') THEN
			_concept_code:='10';
		ELSIF(resultado.tipo_convenio='EXT')THEN
			_concept_code:='50';
		END IF;

		--cuenta de banco procesamos solo los salidas del banco
		IF(resultado.cuenta='11100103' and resultado.tipodoc in ('CDIAR','ING','FAP'))THEN
		  CONTINUE;
		END IF;

		--Buscamos las planillas paso1 y paso2
		IF(resultado.tipodoc IN ('AET','AGA','EXT','FAP'))THEN

			IF(strpos(resultado.numdoc, '_')>0)THEN
			  resultado.tipo_referencia_1:='PLANILLA';
			  resultado.referencia_1:=SUBSTRING(resultado.numdoc,1,strpos(resultado.numdoc, '_')-1);
			ELSE
			   resultado.tipo_referencia_1:='PLANILLA';
			   resultado.referencia_1:=resultado.numdoc;
			END IF;

		END IF;

		IF(resultado.tipodoc IN ('EGR'))THEN

			IF( _tipoanticipo='AGA' AND resultado.cuenta='11100103')THEN --banco gasolina

			       raise notice 'resultado.numdoc: % tipodoc: % resultado.documento_rel: %',resultado.numdoc,resultado.tipodoc,resultado.documento_rel;

				IF(resultado.numdoc like 'BC%')THEN

					PERFORM * FROM tem.egresos_gasolina_banco WHERE cheque=resultado.numdoc and transaccion=resultado.fk_repo_prod;
					IF NOT FOUND THEN
					  CONTINUE;
					END IF;

				ELSIF(resultado.numdoc like 'TR%')THEN
					 CONTINUE;
				END IF;

			ELSE

				--buscamos el documento relacionado de la cuenta de banco
					IF(resultado.tipodoc_rel='')THEN

					    SELECT INTO _documentoRelacionado tipodoc_rel, documento_rel FROM con.comprodet
					    WHERE  numdoc=resultado.numdoc AND numdoc !=documento_rel AND reg_status=''
					    GROUP BY tipodoc_rel,documento_rel;

						resultado.tipodoc_rel:=_documentoRelacionado.tipodoc_rel;
						resultado.documento_rel:=_documentoRelacionado.documento_rel;

					END IF;

					--buscamos la planilla del comprobante
					IF(strpos(resultado.documento_rel, '_')>0)THEN

						resultado.tipo_referencia_1:='PLANILLA';
						resultado.referencia_1:=SUBSTRING(resultado.documento_rel,1,strpos(resultado.documento_rel, '_')-1);

					ELSIF(resultado.cuenta='11100103' AND SUBSTRING(resultado.numdoc,1,2)!='TR')THEN --VALIDAMOS EL BANCO
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
					--	SELECT tipo_operacion,concept_code FROM fin.anticipos_pagos_terceros  where planilla='7572619' and reg_status='' and  concept_code=_concept_code ;
					END IF;

					resultado.tipo_referencia_2:=_documentoRelacionado.tipo_operacion;
					resultado.referencia_2:=_documentoRelacionado.concept_code;

			END IF;

		END IF;

		IF(resultado.tipodoc IN ('FAC'))THEN

			--RAISE NOTICE '_arrCuentasAGA : %',_arrCuentasAGA[2];
			IF(resultado.cuenta IN ('13802701','13802702','13802704','13802602') AND resultado.numdoc not like 'R0%')THEN
				--RAISE NOTICE 'resultado.numdoc: % _arrCuentasAGA : % resultado.detalle: %',resultado.numdoc,_arrCuentasAGA[2],resultado.detalle;
				--tipo operacion
				_intPosTipoOperacion:=strpos(resultado.detalle,_strTipoOperacion)+length(_strTipoOperacion);
				resultado.tipodoc_rel:=SUBSTRING(resultado.detalle,_intPosTipoOperacion,3);
				--numero operacion.
				_intPosTipoOperacion:=strpos(resultado.detalle,_strNumeroOperacion)+length(_strNumeroOperacion);
				resultado.documento_rel:=SUBSTRING(resultado.detalle,_intPosTipoOperacion,(strpos(resultado.detalle,_strFinNumeroOperacion)-_intPosTipoOperacion));


				IF(resultado.tipodoc_rel='AET')THEN
					_concept_code:='01';
				ELSIF(resultado.tipodoc_rel='AGA') THEN
					_concept_code:='10';
				ELSIF(resultado.tipodoc_rel='EXT')THEN
					_concept_code:='50';


				END IF;

				resultado.tipo_referencia_2:=resultado.tipodoc_rel;
				resultado.referencia_2:=_concept_code;

			END IF;

			--Agregamos la planilla
			IF(strpos(resultado.documento_rel, '_')>0)THEN
			  resultado.tipo_referencia_1:='PLANILLA';
			  resultado.referencia_1:=SUBSTRING(resultado.documento_rel,1,strpos(resultado.documento_rel, '_')-1);
			ELSE
			   resultado.tipo_referencia_1:='PLANILLA';
			   resultado.referencia_1:=resultado.documento_rel;
			END IF;

			SELECT INTO _recordFactura
			             fecha_vencimiento,
			             valor_saldo,
				     CASE WHEN 	num_ingreso_ultimo_ingreso ='' AND resultado.numdoc  LIKE 'PP%'  THEN
					 (SELECT COALESCE(num_ingreso,'') FROM con.ingreso_detalle   where documento=resultado.numdoc  GROUP BY num_ingreso limit 1)
				     ELSE
			                 num_ingreso_ultimo_ingreso
			             END AS num_ingreso_ultimo_ingreso
			FROM con.factura  WHERE documento=resultado.numdoc limit 1;

			resultado.referencia_3:=_recordFactura.fecha_vencimiento;
			resultado.valor_saldo=_recordFactura.valor_saldo;
			resultado.dias_vencimiento:=resultado.referencia_3::date-resultado.fechadoc::date;
                        resultado.numero_ingreso:=_recordFactura.num_ingreso_ultimo_ingreso;


			IF(resultado.numdoc  LIKE 'PP%')THEN
			     resultado.periodo_ingreso:=(SELECT periodo FROM con.ingreso  WHERE num_ingreso= resultado.numero_ingreso);
			END IF;

			IF(resultado.valor_saldo>0)THEN
			   resultado.dias_mora:=now()::DATE-resultado.referencia_3::DATE;
			ELSE
			   resultado.dias_mora:='Cancelado';
			END IF;

			RETURN NEXT resultado;

			CONTINUE;
		END IF;


		RETURN NEXT resultado;

	    END LOOP;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_movimiento_tsp_paso_cartera(integer, character varying, character varying, character varying)
  OWNER TO postgres;
