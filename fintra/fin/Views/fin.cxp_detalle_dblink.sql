-- View: fin.cxp_detalle_dblink

-- DROP VIEW fin.cxp_detalle_dblink;

CREATE OR REPLACE VIEW fin.cxp_detalle_dblink AS
 SELECT cxp_items_doc_dblink.reg_status, cxp_items_doc_dblink.dstrct, cxp_items_doc_dblink.proveedor, cxp_items_doc_dblink.tipo_documento, cxp_items_doc_dblink.documento, cxp_items_doc_dblink.item, cxp_items_doc_dblink.descripcion, cxp_items_doc_dblink.vlr, cxp_items_doc_dblink.vlr_me, cxp_items_doc_dblink.codigo_cuenta, cxp_items_doc_dblink.codigo_abc, cxp_items_doc_dblink.planilla, cxp_items_doc_dblink.last_update, cxp_items_doc_dblink.user_update, cxp_items_doc_dblink.creation_date, cxp_items_doc_dblink.creation_user, cxp_items_doc_dblink.base, cxp_items_doc_dblink.codcliarea, cxp_items_doc_dblink.tipcliarea, cxp_items_doc_dblink.concepto, cxp_items_doc_dblink.auxiliar, cxp_items_doc_dblink.tipo_referencia_1, cxp_items_doc_dblink.referencia_1, cxp_items_doc_dblink.tipo_referencia_2, cxp_items_doc_dblink.referencia_2, cxp_items_doc_dblink.tipo_referencia_3, cxp_items_doc_dblink.referencia_3
   FROM dblink('dbname=selectrik port=5432 host=localhost user=postgres password=bdversion17'::text, 'SELECT reg_status, dstrct, proveedor, tipo_documento, documento, item,
											       descripcion, vlr, vlr_me, codigo_cuenta, codigo_abc, planilla,
											       last_update, user_update, creation_date, creation_user, base,
											       codcliarea, tipcliarea, concepto, auxiliar, tipo_referencia_1,
											       referencia_1, tipo_referencia_2, referencia_2, tipo_referencia_3,
											       referencia_3 FROM fin.cxp_items_doc '::text) cxp_items_doc_dblink(reg_status character varying(1), dstrct character varying(15), proveedor character varying(15), tipo_documento character varying(15), documento character varying(30), item character varying(30), descripcion text, vlr moneda, vlr_me moneda, codigo_cuenta character varying(30), codigo_abc character varying(30), planilla character varying(15), last_update timestamp without time zone, user_update character varying, creation_date timestamp without time zone, creation_user character varying(15), base character varying(3), codcliarea character varying(10), tipcliarea character varying(10), concepto text, auxiliar character varying(25), tipo_referencia_1 character varying(5), referencia_1 character varying(30), tipo_referencia_2 character varying(5), referencia_2 character varying(30), tipo_referencia_3 character varying(5), referencia_3 character varying(100));

ALTER TABLE fin.cxp_detalle_dblink
  OWNER TO postgres;
