-- Table: fin.cxp_items_doc

-- DROP TABLE fin.cxp_items_doc;

CREATE TABLE fin.cxp_items_doc
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(15) NOT NULL DEFAULT ''::character varying,
  proveedor character varying(15) NOT NULL DEFAULT ''::character varying,
  tipo_documento character varying(15) NOT NULL DEFAULT ''::character varying,
  documento character varying(30) NOT NULL DEFAULT ''::character varying,
  item character varying(30) NOT NULL DEFAULT ''::character varying,
  descripcion text NOT NULL DEFAULT ''::text,
  vlr moneda, -- Valor del documento
  vlr_me moneda, -- Valor moneda extranjera
  codigo_cuenta character varying(30) NOT NULL DEFAULT ''::character varying,
  codigo_abc character varying(30) NOT NULL DEFAULT ''::character varying, -- codigo para abcosting
  planilla character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT (now())::timestamp without time zone,
  user_update character varying NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT (now())::timestamp without time zone,
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  base character varying(3) DEFAULT ''::character varying,
  codcliarea character varying(10) NOT NULL DEFAULT ''::character varying, -- codigo de area administrativa o cliente
  tipcliarea character varying(10) NOT NULL DEFAULT ''::character varying, -- tipo de area administrativa o cliente
  concepto text NOT NULL DEFAULT ''::text, -- concepto de pago del item de la factura
  auxiliar character varying(25) NOT NULL DEFAULT ''::character varying, -- Codigo del auxiliar
  tipo_referencia_1 character varying(5) NOT NULL DEFAULT ''::character varying,
  referencia_1 character varying(30) NOT NULL DEFAULT ''::character varying,
  tipo_referencia_2 character varying(5) NOT NULL DEFAULT ''::character varying,
  referencia_2 character varying(30) NOT NULL DEFAULT ''::character varying,
  tipo_referencia_3 character varying(5) NOT NULL DEFAULT ''::character varying,
  referencia_3 character varying(100) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE fin.cxp_items_doc
  OWNER TO postgres;
COMMENT ON TABLE fin.cxp_items_doc
  IS 'Items del Documento por pagar';
COMMENT ON COLUMN fin.cxp_items_doc.vlr IS 'Valor del documento';
COMMENT ON COLUMN fin.cxp_items_doc.vlr_me IS 'Valor moneda extranjera';
COMMENT ON COLUMN fin.cxp_items_doc.codigo_abc IS 'codigo para abcosting';
COMMENT ON COLUMN fin.cxp_items_doc.codcliarea IS 'codigo de area administrativa o cliente';
COMMENT ON COLUMN fin.cxp_items_doc.tipcliarea IS 'tipo de area administrativa o cliente';
COMMENT ON COLUMN fin.cxp_items_doc.concepto IS 'concepto de pago del item de la factura';
COMMENT ON COLUMN fin.cxp_items_doc.auxiliar IS 'Codigo del auxiliar';


