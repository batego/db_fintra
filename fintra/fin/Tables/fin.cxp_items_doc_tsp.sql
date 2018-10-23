-- Table: fin.cxp_items_doc_tsp

-- DROP TABLE fin.cxp_items_doc_tsp;

CREATE TABLE fin.cxp_items_doc_tsp
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
  resp_gasto character varying(15) NOT NULL DEFAULT ''::character varying, -- Responsable Gasto
  fecha_envio_ws timestamp without time zone, -- fecha en la que se envio por ultima vez el registro del servidor al cliente  a traves del web service
  creation_date_real timestamp without time zone DEFAULT now(), -- fecha de creacion real
  pk_novedad integer NOT NULL DEFAULT (-1) -- llave primaria
)
WITH (
  OIDS=TRUE
);
ALTER TABLE fin.cxp_items_doc_tsp
  OWNER TO postgres;
COMMENT ON TABLE fin.cxp_items_doc_tsp
  IS 'Items del Documento por pagar';
COMMENT ON COLUMN fin.cxp_items_doc_tsp.vlr IS 'Valor del documento';
COMMENT ON COLUMN fin.cxp_items_doc_tsp.vlr_me IS 'Valor moneda extranjera';
COMMENT ON COLUMN fin.cxp_items_doc_tsp.codigo_abc IS 'codigo para abcosting';
COMMENT ON COLUMN fin.cxp_items_doc_tsp.codcliarea IS 'codigo de area administrativa o cliente';
COMMENT ON COLUMN fin.cxp_items_doc_tsp.tipcliarea IS 'tipo de area administrativa o cliente';
COMMENT ON COLUMN fin.cxp_items_doc_tsp.concepto IS 'concepto de pago del item de la factura';
COMMENT ON COLUMN fin.cxp_items_doc_tsp.auxiliar IS 'Codigo del auxiliar';
COMMENT ON COLUMN fin.cxp_items_doc_tsp.resp_gasto IS 'Responsable Gasto';
COMMENT ON COLUMN fin.cxp_items_doc_tsp.fecha_envio_ws IS 'fecha en la que se envio por ultima vez el registro del servidor al cliente  a traves del web service';
COMMENT ON COLUMN fin.cxp_items_doc_tsp.creation_date_real IS 'fecha de creacion real';
COMMENT ON COLUMN fin.cxp_items_doc_tsp.pk_novedad IS 'llave primaria';


