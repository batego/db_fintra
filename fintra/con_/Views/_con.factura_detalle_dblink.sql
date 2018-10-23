-- View: con.factura_detalle_dblink

-- DROP VIEW con.factura_detalle_dblink;

CREATE OR REPLACE VIEW con.factura_detalle_dblink AS
 SELECT facturadetalleselectrik.reg_status, facturadetalleselectrik.dstrct, facturadetalleselectrik.tipo_documento, facturadetalleselectrik.documento, facturadetalleselectrik.item, facturadetalleselectrik.nit, facturadetalleselectrik.concepto, facturadetalleselectrik.numero_remesa, facturadetalleselectrik.descripcion, facturadetalleselectrik.codigo_cuenta_contable, facturadetalleselectrik.cantidad, facturadetalleselectrik.valor_unitario, facturadetalleselectrik.valor_unitariome, facturadetalleselectrik.valor_item, facturadetalleselectrik.valor_itemme, facturadetalleselectrik.valor_tasa, facturadetalleselectrik.moneda, facturadetalleselectrik.last_update, facturadetalleselectrik.user_update, facturadetalleselectrik.creation_date, facturadetalleselectrik.creation_user, facturadetalleselectrik.base, facturadetalleselectrik.auxiliar, facturadetalleselectrik.valor_ingreso, facturadetalleselectrik.tipo_documento_rel, facturadetalleselectrik.transaccion, facturadetalleselectrik.documento_relacionado, facturadetalleselectrik.tipo_referencia_1, facturadetalleselectrik.referencia_1, facturadetalleselectrik.tipo_referencia_2, facturadetalleselectrik.referencia_2, facturadetalleselectrik.tipo_referencia_3, facturadetalleselectrik.referencia_3
   FROM dblink('dbname=selectrik port=5432 host=localhost user=postgres password=bdversion17'::text, 'SELECT reg_status, dstrct, tipo_documento, documento, item, nit, concepto,
											       numero_remesa, descripcion, codigo_cuenta_contable, cantidad,
											       valor_unitario, valor_unitariome, valor_item, valor_itemme, valor_tasa,
											       moneda, last_update, user_update, creation_date, creation_user,
											       base, auxiliar, valor_ingreso, tipo_documento_rel, transaccion,
											       documento_relacionado, tipo_referencia_1, referencia_1, tipo_referencia_2,
											       referencia_2, tipo_referencia_3, referencia_3
											       FROM con.factura_detalle WHERE tipo_documento=''FAC'' AND reg_status='''''::text) facturadetalleselectrik(reg_status character varying, dstrct character varying, tipo_documento character varying, documento character varying, item numeric, nit character varying, concepto character varying, numero_remesa character varying, descripcion text, codigo_cuenta_contable character varying, cantidad numeric, valor_unitario moneda, valor_unitariome moneda, valor_item moneda, valor_itemme moneda, valor_tasa numeric, moneda character varying, last_update timestamp without time zone, user_update character varying, creation_date timestamp without time zone, creation_user character varying, base character varying, auxiliar character varying, valor_ingreso moneda, tipo_documento_rel character varying, transaccion integer, documento_relacionado text, tipo_referencia_1 character varying, referencia_1 character varying, tipo_referencia_2 character varying, referencia_2 character varying, tipo_referencia_3 character varying, referencia_3 character varying);

ALTER TABLE con.factura_detalle_dblink
  OWNER TO postgres;
