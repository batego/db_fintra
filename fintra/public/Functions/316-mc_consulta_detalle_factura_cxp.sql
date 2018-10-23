-- Function: mc_consulta_detalle_factura_cxp(character varying)

-- DROP FUNCTION mc_consulta_detalle_factura_cxp(character varying);

CREATE OR REPLACE FUNCTION mc_consulta_detalle_factura_cxp(_documento character varying)
  RETURNS SETOF rs_type_detalle_factura AS
$BODY$ 
DECLARE 
 rs rs_type_detalle_factura;
 detalleFacturaRecord record;
 impuestosRecord record;
 contador integer:=0;
 
BEGIN


	FOR detalleFacturaRecord IN 	
					SELECT 
						cxpdet.item::numeric,
						cxpdet.tipo_documento::varchar,
						cxpdet.documento::varchar,
						cxpdet.proveedor::numeric,
						get_nombp(cxpdet.referencia_2)::varchar as empleado,
						cxpdet.codigo_cuenta::varchar,
						cxpdet.creation_date::date,
						cxpdet.descripcion::varchar,
						0.00::numeric AS vlr,
						cxpdet.vlr::numeric as valor,
						''::varchar AS cod_impuesto_iva,
						0.00::numeric AS porc_iva,
						0.00::numeric AS valor_iva,
						''::varchar AS cod_impuesto_rica,
						0.00::numeric AS porc_rica,
						0.00::numeric AS valor_rica,
						''::varchar AS cod_impuesto_riva,
						0.00::numeric AS porc_riva,
						0.00::numeric AS valor_riva,
						''::varchar AS cod_impuesto_rtfuente,
						0.00::numeric AS porc_rtfuente,
						0.00::numeric AS valor_rtfuente,
						cxpdet.referencia_1::varchar,
						cxpdet.tipo_referencia_1::varchar,
						cxpdet.referencia_2::varchar,
						cxpdet.tipo_referencia_2::varchar,
						cxpdet.referencia_3::varchar,
						cxpdet.tipo_referencia_3::varchar,
						cxpcab.proveedor as provedor_cab
					FROM    fin.cxp_doc cxpcab
					INNER JOIN fin.cxp_items_doc cxpdet on (cxpcab.documento = cxpdet.documento )
					WHERE cxpcab.documento =_documento and cxpcab.reg_status='' and cxpcab.tipo_documento='FAP'
					ORDER BY cxpdet.item 

	LOOP
		--1.)asignamos el detalle de la facura...
		rs:=detalleFacturaRecord;

		--2.)buscar lso impuestos de cada factura..	
		 contador:=contador+1;
		 
		 rs.vlr:= detalleFacturaRecord.valor;		
		 FOR impuestosRecord IN 
			select  * from fin.cxp_imp_doc where proveedor=detalleFacturaRecord.provedor_cab and proveedor_rel=detalleFacturaRecord.referencia_2 and documento=_documento
		 LOOP
			raise notice 'contador: % impuestosRecord:  %',contador,impuestosRecord;
			raise notice 'rs.vlr  %',rs.vlr;
			IF(impuestosRecord.cod_impuesto like 'IVA%')THEN 
				rs.cod_impuesto_iva:=impuestosRecord.cod_impuesto;
				rs.porc_iva:= impuestosRecord.porcent_impuesto;
				rs.valor_iva:=impuestosRecord.vlr_total_impuesto;
				rs.vlr:= rs.vlr + rs.valor_iva;
				raise notice 'rs.vlr  %',rs.vlr;
			END IF;

			IF(impuestosRecord.cod_impuesto like 'RICA%')THEN 
				rs.cod_impuesto_rica:=impuestosRecord.cod_impuesto;
				rs.porc_rica:= impuestosRecord.porcent_impuesto;
				rs.valor_rica:=impuestosRecord.vlr_total_impuesto;
				rs.vlr= rs.vlr + rs.valor_rica;
				raise notice 'rs.vlr  %',rs.vlr;	
				
			END IF;
			
			IF(impuestosRecord.cod_impuesto like 'RIVA%')THEN 
				rs.cod_impuesto_riva:=impuestosRecord.cod_impuesto;
				rs.porc_riva:= impuestosRecord.porcent_impuesto;
				rs.valor_riva:=impuestosRecord.vlr_total_impuesto;
				rs.vlr:= rs.vlr + rs.valor_riva;
				raise notice 'rs.vlr  %',rs.vlr;
			END IF;

			IF(impuestosRecord.cod_impuesto like 'RETF%')THEN 
				rs.cod_impuesto_rtfuente:=impuestosRecord.cod_impuesto;
				rs.porc_rtfuente:= impuestosRecord.porcent_impuesto;
				rs.valor_rtfuente:=impuestosRecord.vlr_total_impuesto;
				rs.vlr:= rs.vlr + rs.valor_rtfuente;
				raise notice 'rs.vlr  %',rs.vlr;
			END IF;

			rs.multiservicio  :=detalleFacturaRecord.referencia_3;
			rs.numos  :=detalleFacturaRecord.tipo_referencia_3;
			rs.proveedor := detalleFacturaRecord.referencia_2;
		 END LOOP;

		
		return next rs;	

	END LOOP;
		   
END $BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION mc_consulta_detalle_factura_cxp(character varying)
  OWNER TO postgres;

