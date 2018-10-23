-- Table: cxp_items_doc_tsp

-- DROP TABLE cxp_items_doc_tsp;

CREATE TABLE cxp_items_doc_tsp
(
  reg_status character varying(1),
  dstrct character varying(15),
  proveedor character varying(15),
  tipo_documento character varying(15),
  documento character varying(30),
  item character varying(30),
  descripcion text,
  vlr moneda,
  vlr_me moneda,
  codigo_cuenta character varying(30),
  codigo_abc character varying(30),
  planilla character varying(15),
  last_update timestamp without time zone,
  user_update character varying,
  creation_date timestamp without time zone,
  creation_user character varying(15),
  base character varying(3),
  codcliarea character varying(10),
  tipcliarea character varying(10),
  concepto text,
  auxiliar character varying(25)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cxp_items_doc_tsp
  OWNER TO postgres;
GRANT ALL ON TABLE cxp_items_doc_tsp TO postgres;
GRANT SELECT ON TABLE cxp_items_doc_tsp TO msoto;

