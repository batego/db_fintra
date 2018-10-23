-- Function: eg_reporte_produccion_consolidado(character varying, character varying, character varying, character varying, integer)

-- DROP FUNCTION eg_reporte_produccion_consolidado(character varying, character varying, character varying, character varying, integer);

CREATE OR REPLACE FUNCTION eg_reporte_produccion_consolidado(_filtro character varying, _periodoi character varying, _periodof character varying, _concept_code character varying, _status integer)
  RETURNS SETOF record AS
$BODY$

DECLARE
   _separatorDate VARCHAR:='-';
   _dateStart VARCHAR:=SUBSTRING(current_date,1,5)||'01'||_separatorDate||'01' ;
   _dateEnd VARCHAR:=SUBSTRING(current_date,1,5)||'12'||_separatorDate||'31' ;
   _auxPeriodo VARCHAR:='';

   _recordResult RECORD;

BEGIN

	--Filtro
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

        --crear tabla temporal
       -- DROP TABLE IF EXISTS tem.rows_span_table;
	DELETE FROM tem.rows_span_table ;
        INSERT INTO tem.rows_span_table
         ( --   CREATE TABLE tem.rows_span_table
		SELECT periodo_anticipo
			       ,sum(valor) as valor
			       ,sum(valor_descuento) as valor_descuento
			       ,sum(valor_neto) as valor_neto
			       ,sum(valor_combancaria) as valor_combancaria
			       ,sum(vlr_consignacion) as vlr_consignacion
			       ,count(0) as rows_span
			 FROM (
			 SELECT
				periodo_anticipo
				,periodo_contabilizacion
				,sum(valor) as valor
				,sum(valor_descuento) as valor_descuento
				,sum(valor_neto) as valor_neto
				,sum(valor_combancaria) as valor_combancaria
				,sum(vlr_consignacion) as vlr_consignacion
				FROM (

				 SELECT replace(SUBSTRING(a.creation_date,1,7),'-','') as periodo_anticipo,
				  (select periodo from con.comprobante where numdoc = a.numero_operacion and tipodoc = a.tipo_operacion limit 1) as periodo_contabilizacion
				  ,a.vlr as valor
				  ,a.vlr_descuento as valor_descuento
				  ,a.vlr_neto as valor_neto
				  ,a.vlr_combancaria as valor_combancaria
				  ,a.vlr_consignacion as vlr_consignacion
				 FROM fin.anticipos_pagos_terceros as a
				 INNER JOIN proveedor as b on (b.nit = a.proveedor_anticipo)
				 INNER JOIN nit as c on (c.cedula = a.pla_owner)
				 LEFT JOIN fin.anticipos_pagos_terceros_tsp as  aptsp on (a.id=aptsp.id)
				WHERE a.dstrct = 'FINV'
				  AND a.proveedor_anticipo = '802022016'
				 AND CASE WHEN _filtro ='4' THEN (REPLACE(SUBSTRING(a.fecha_anticipo,1,7),'-','')::INTEGER  BETWEEN _periodoI::INTEGER and _periodoF::INTEGER)
				      ELSE (a.fecha_anticipo  BETWEEN _dateStart::DATE and _dateEnd::DATE )   END
				  AND a.planilla != 'SAL ABPRES'
				  AND CASE WHEN _status=1 THEN a.reg_status =''
					   WHEN _status=2 THEN a.reg_status ='A'
					   ELSE true END
				  AND CASE WHEN _concept_code !='' THEN  a.concept_code=_concept_code ELSE a.concept_code in ('01','10','50') END
				  AND CASE WHEN _concept_code='01' THEN a.con_ant_tercero='02' ELSE TRUE END

				)ta
			  GROUP BY periodo_anticipo ,periodo_contabilizacion
			)tabla
			   GROUP BY periodo_anticipo
			   order by periodo_anticipo::integer);



	FOR _recordResult IN (
				SELECT
					periodo_anticipo::varchar
					,periodo_contabilizacion::varchar
					,descripcion::varchar
					,sum(valor)::numeric as valor
					,sum(valor_descuento)::numeric as valor_descuento
					,sum(valor_neto)::numeric as valor_neto
					,sum(valor_combancaria)::numeric as valor_combancaria
					,sum(vlr_consignacion)::numeric as vlr_consignacion
					,1::INTEGER as row_span
					,''::VARCHAR AS display
				       FROM (
					SELECT
					 a.reg_status,
					 replace(SUBSTRING(a.creation_date,1,7),'-','') as periodo_anticipo,
					 (select periodo from con.comprobante where numdoc = a.numero_operacion and tipodoc = a.tipo_operacion limit 1) as periodo_contabilizacion
					    ,CASE
						WHEN (coalesce(a.concept_code,'')='01' AND coalesce(a.con_ant_tercero,'')='01') THEN 'EFECTIVO'
						WHEN (coalesce(a.concept_code,'')='01' AND coalesce(a.con_ant_tercero,'')='02') THEN 'TRANSFERENCIA'
						WHEN coalesce(a.concept_code,'')='50' THEN 'PRONTO PAGO'
						WHEN coalesce(a.concept_code,'')='10' THEN 'GASOLINA' ELSE 'ANTICIPO'
					     END AS descripcion
					     ,a.concept_code
					     ,a.vlr as valor
					     ,a.vlr_descuento as valor_descuento
					     ,a.vlr_neto as valor_neto
					     ,a.vlr_combancaria as valor_combancaria
					     ,a.vlr_consignacion as vlr_consignacion
					 FROM fin.anticipos_pagos_terceros as a
					 INNER JOIN proveedor as b on (b.nit = a.proveedor_anticipo)
					 INNER JOIN nit as c on (c.cedula = a.pla_owner)
					 LEFT JOIN fin.anticipos_pagos_terceros_tsp as  aptsp on (a.id=aptsp.id)
					WHERE a.dstrct = 'FINV'
					  AND a.proveedor_anticipo = '802022016'
					  AND CASE WHEN _filtro ='4' THEN (REPLACE(SUBSTRING(a.fecha_anticipo,1,7),'-','')::INTEGER  BETWEEN _periodoI::INTEGER and _periodoF::INTEGER)
					      ELSE (a.fecha_anticipo  BETWEEN _dateStart::DATE and _dateEnd::DATE )   END
					  AND a.planilla != 'SAL ABPRES'
					  AND CASE WHEN _status=1 THEN a.reg_status =''
						   WHEN _status=2 THEN a.reg_status ='A'
						   ELSE true END
					  --AND a.concept_code=_concept_code
					  AND CASE WHEN _concept_code !='' THEN  a.concept_code=_concept_code ELSE a.concept_code in ('01','10','50') END
					  AND CASE WHEN _concept_code='01' THEN a.con_ant_tercero='02' ELSE TRUE END
					)tabla
					GROUP BY
					periodo_anticipo,
					periodo_contabilizacion,
					descripcion
					order by periodo_anticipo,periodo_contabilizacion::numeric
					)
		LOOP
				IF(_auxPeriodo='')THEN
				    _auxPeriodo:=_recordResult.periodo_anticipo;
				    _recordResult.display='block';
				    _recordResult.row_span:=(SELECT rows_span FROM tem.rows_span_table WHERE periodo_anticipo=_recordResult.periodo_anticipo);
				ELSIF(_auxPeriodo=_recordResult.periodo_anticipo)THEN
				     _recordResult.display='none';
				ELSE
				    _auxPeriodo:=_recordResult.periodo_anticipo;
				    _recordResult.display='block';
				    _recordResult.row_span:=(SELECT rows_span FROM tem.rows_span_table WHERE periodo_anticipo=_recordResult.periodo_anticipo);
				END IF;


				RAISE NOTICE '_recordResult.row_span : %',_recordResult.row_span;

				return next _recordResult;


		END LOOP;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION eg_reporte_produccion_consolidado(character varying, character varying, character varying, character varying, integer)
  OWNER TO postgres;
