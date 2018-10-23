-- Table: con.factura_ingresoerradocomparar

-- DROP TABLE con.factura_ingresoerradocomparar;

CREATE TABLE con.factura_ingresoerradocomparar
(
  factura character varying(10),
  valor_ingreso moneda
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.factura_ingresoerradocomparar
  OWNER TO postgres;
GRANT ALL ON TABLE con.factura_ingresoerradocomparar TO postgres;
GRANT SELECT ON TABLE con.factura_ingresoerradocomparar TO msoto;

