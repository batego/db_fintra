-- Table: factura_detalle_tsp

-- DROP TABLE factura_detalle_tsp;

CREATE TABLE factura_detalle_tsp
(
  reg_status character varying(1),
  dstrct character varying(4),
  tipo_documento character varying(5),
  documento character varying(10),
  item numeric(4,0),
  nit character varying(15),
  concepto character varying(6),
  numero_remesa character varying(10),
  descripcion text,
  codigo_cuenta_contable character varying(30),
  cantidad numeric(15,4),
  valor_unitario moneda,
  valor_unitariome moneda,
  valor_item moneda,
  valor_itemme moneda,
  valor_tasa numeric(15,6),
  moneda character varying(3),
  last_update timestamp without time zone,
  user_update character varying(10),
  creation_date timestamp without time zone,
  creation_user character varying(10),
  base character varying(3),
  auxiliar character varying(18)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE factura_detalle_tsp
  OWNER TO postgres;
GRANT ALL ON TABLE factura_detalle_tsp TO postgres;
GRANT SELECT ON TABLE factura_detalle_tsp TO msoto;

