-- Table: con.factura_cf

-- DROP TABLE con.factura_cf;

CREATE TABLE con.factura_cf
(
  nm character varying(10),
  cf character varying(10),
  valor_cf moneda,
  cliente_cf character varying(10),
  pm character varying(10),
  descripcion_pm text,
  valor_pm moneda,
  valor_iva_eca numeric,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.factura_cf
  OWNER TO postgres;
GRANT ALL ON TABLE con.factura_cf TO postgres;
GRANT SELECT ON TABLE con.factura_cf TO msoto;

