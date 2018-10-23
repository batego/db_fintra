-- Table: con.factura_detalle

-- DROP TABLE con.factura_detalle;

CREATE TABLE con.factura_detalle
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  tipo_documento character varying(5) NOT NULL DEFAULT ''::character varying, -- tipo de documento como factura, prefactura, etc
  documento character varying(10) NOT NULL DEFAULT ''::character varying, -- numero de la factura
  item numeric(7,0) NOT NULL DEFAULT 0, -- numero de item secuencial
  nit character varying(15) DEFAULT ''::character varying, -- nit del cliente
  concepto character varying(6) NOT NULL DEFAULT ''::character varying,
  numero_remesa character varying(10) NOT NULL DEFAULT ''::character varying,
  descripcion text NOT NULL DEFAULT ''::text,
  codigo_cuenta_contable character varying(30) NOT NULL DEFAULT ''::character varying,
  cantidad numeric(15,4) NOT NULL DEFAULT 0,
  valor_unitario moneda,
  valor_unitariome moneda,
  valor_item moneda,
  valor_itemme moneda,
  valor_tasa numeric(15,6) NOT NULL DEFAULT 0,
  moneda character varying(3) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  auxiliar character varying(18) DEFAULT ''::character varying,
  valor_ingreso moneda,
  tipo_documento_rel character varying(15) NOT NULL DEFAULT ''::character varying, -- Tipo documento asociado al comprobante diario INM o IPM que contabiliza el item dependiendo de la cuenta
  transaccion integer NOT NULL DEFAULT 0, -- Grupo transaccion del comprobante diario INM o IPM que contabiliza el item  dependiendo de la cuenta contable
  documento_relacionado text NOT NULL DEFAULT ''::text, -- Numero de documento del comprobante diario INM o IPM que contabiliza el item dependiendo de la cuenta
  tipo_referencia_1 character varying(5) NOT NULL DEFAULT ''::character varying,
  referencia_1 character varying(30) NOT NULL DEFAULT ''::character varying,
  tipo_referencia_2 character varying(5) NOT NULL DEFAULT ''::character varying,
  referencia_2 character varying(30) NOT NULL DEFAULT ''::character varying,
  tipo_referencia_3 character varying(5) NOT NULL DEFAULT ''::character varying,
  referencia_3 character varying(30) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE con.factura_detalle
  OWNER TO postgres;
GRANT ALL ON TABLE con.factura_detalle TO postgres;
GRANT SELECT ON TABLE con.factura_detalle TO msoto;
COMMENT ON COLUMN con.factura_detalle.tipo_documento IS 'tipo de documento como factura, prefactura, etc';
COMMENT ON COLUMN con.factura_detalle.documento IS 'numero de la factura';
COMMENT ON COLUMN con.factura_detalle.item IS 'numero de item secuencial';
COMMENT ON COLUMN con.factura_detalle.nit IS 'nit del cliente';
COMMENT ON COLUMN con.factura_detalle.tipo_documento_rel IS 'Tipo documento asociado al comprobante diario INM o IPM que contabiliza el item dependiendo de la cuenta';
COMMENT ON COLUMN con.factura_detalle.transaccion IS 'Grupo transaccion del comprobante diario INM o IPM que contabiliza el item  dependiendo de la cuenta contable';
COMMENT ON COLUMN con.factura_detalle.documento_relacionado IS 'Numero de documento del comprobante diario INM o IPM que contabiliza el item dependiendo de la cuenta';


-- Trigger: cambiar_cuentas_ca_mi_reest on con.factura_detalle

-- DROP TRIGGER cambiar_cuentas_ca_mi_reest ON con.factura_detalle;

CREATE TRIGGER cambiar_cuentas_ca_mi_reest
  AFTER INSERT
  ON con.factura_detalle
  FOR EACH ROW
  EXECUTE PROCEDURE con.cambiar_cuentas_reestructuracion_micro_ca_mi();


