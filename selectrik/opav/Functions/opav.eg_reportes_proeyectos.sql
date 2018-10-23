-- Function: opav.eg_reportes_proeyectos()

-- DROP FUNCTION opav.eg_reportes_proeyectos();

CREATE OR REPLACE FUNCTION opav.eg_reportes_proeyectos()
  RETURNS SETOF opav.rs_reporte_proyecto AS
$BODY$
DECLARE

rs opav.rs_reporte_proyecto;
recordReporte record;
recordCostosInymec record;
recordCostosProvi record;
_totalComision numeric:=0;
_auxDocumento varchar:='';
_auxProveedor varchar:='';
_auxTipoDocumento varchar:='';
_auxOrdenCompra varchar:='';
_utilizado numeric:=0.00;
_itera integer:=0;


BEGIN

 FOR recordReporte IN (
			SELECT
				oferta.num_os AS multiservicio,
				oferta.id_solicitud,
				oferta.nombre_proyecto,
				get_nombrecliente(oferta.id_cliente) as nombre_cliente,
				ctz.subtotal AS valor_venta,
				0.00::numeric as utilizado,
				0.00::numeric as rentabilidad,
				ctz.perc_administracion AS "% administracion",
				ctz.perc_imprevisto AS "% imprevisto",
				ctz.perc_utilidad AS "% utilidad",
				ctz.administracion AS vlr_administracion,
				ctz.imprevisto AS vlr_imprevisto,
				ctz.utilidad AS vlr_utilidad,
				CASE WHEN ctz.perc_aiu >0 THEN ctz.valor_aiu
				     ELSE  ctz.subtotal END AS valor_antes_iva,
				ctz.perc_iva AS "% iva",
				ctz.valor_iva,
				ctz.total,
				oferta.tipodistribucion as esquema,
				tipo_dis.porc_opav AS "% OPAV",
				tipo_dis.porc_fintra AS "% FINTRA",
				tipo_dis.porc_provintegral AS "% PROVINTEGRAL",
				tipo_dis.porc_interventoria AS "% INTERVENTORIA",
				(tipo_dis.porc_opav+tipo_dis.porc_fintra+tipo_dis.porc_provintegral+tipo_dis.porc_interventoria )AS total_esquema,
				round(((tipo_dis.porc_opav+tipo_dis.porc_fintra+tipo_dis.porc_provintegral+tipo_dis.porc_interventoria )/100)+1,3) as sub_total_esquema,
				tipo_dis.porc_eca AS "% ECA",
				round((tipo_dis.porc_eca/100)+1,3) AS sub_total_eca,
				0.0::numeric(11,3) AS total_comision,
				0.0::numeric(11,3) AS valor_contratista_antes_aiu,
				modalidad_comercial
			FROM tem.sl_cotizacion ctz
			INNER JOIN opav.acciones acc ON (ctz.id_accion=acc.id_accion)
			INNER JOIN opav.ofertas oferta ON (acc.id_solicitud=oferta.id_solicitud)
			INNER JOIN opav.tipo_distribucion_eca  tipo_dis ON (oferta.tipodistribucion=tipo_dis.tipo)
			WHERE case when noesvaloragregado=1 then valor_agregado='N' ELSE valor_agregado='S' END-- ctz.id_accion=9036275
			)
	LOOP
		_itera:=_itera+1;
		RAISE NOTICE 'multiservicio: % recordReporte.id_solicitud :% _itera :% ',recordReporte.multiservicio,recordReporte.id_solicitud,_itera;
		--1.) Calculamos el valor total de la comisiones

		_totalComision:=recordReporte.sub_total_esquema*recordReporte.sub_total_eca;
		recordReporte.total_comision:=_totalComision;

		--2.)Calculamos el costos contratista
		raise notice '_totalComision:% ',_totalComision;
		recordReporte.valor_contratista_antes_aiu:=ROUND(recordReporte.valor_venta/_totalComision);

		IF(recordReporte.modalidad_comercial=1)THEN --tiene aiu

			--3)utilizado inymec
			_utilizado:=coalesce((SELECT sum(valor_total_con_iva) FROM opav.eg_costos_inymec(recordReporte.multiservicio)),0.00);
			raise notice 'utilizado: %',_utilizado;

			--4.)utilizado provintegral
			_utilizado:=_utilizado+coalesce((SELECT sum(valor_total_con_iva) FROM opav.eg_costos_provintegral(recordReporte.id_solicitud)),0.00);

			--5.)recordReporte.valor_contratista_antes_aiu:=.
			raise notice 'recordReporte.valor_venta: % administracion: % imprevisto: % utilidad: %',recordReporte.valor_venta,recordReporte."% administracion",recordReporte."% imprevisto",recordReporte."% utilidad";
			recordReporte.valor_contratista_antes_aiu:=opav.eg_calcular_costo_contratista_aiu(recordReporte.valor_venta,recordReporte."% administracion",recordReporte."% imprevisto",recordReporte."% utilidad",_totalComision);

		ELSE
			--3)utilizado inymec
			_utilizado:=coalesce((SELECT sum(valor_antes_iva) FROM opav.eg_costos_inymec(recordReporte.multiservicio)),0.00);
			raise notice 'utilizado: %',_utilizado;

			--4.)utilizado provintegral
			_utilizado:=_utilizado+coalesce((SELECT sum(valor_antes_iva) FROM opav.eg_costos_provintegral(recordReporte.id_solicitud)),0.00);


		END IF;

		raise notice '_utilizado: % recordReporte.valor_contratista_antes_aiu: %' ,_utilizado,recordReporte.valor_contratista_antes_aiu;
		recordReporte.utilizado:=_utilizado;
		recordReporte.rentabilidad:=(_utilizado/recordReporte.valor_contratista_antes_aiu)*100;
		rs:=recordReporte;
		RETURN NEXT rs;

	END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION opav.eg_reportes_proeyectos()
  OWNER TO postgres;
