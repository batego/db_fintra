-- Table: con.factura_consorcio20100302b

-- DROP TABLE con.factura_consorcio20100302b;

CREATE TABLE con.factura_consorcio20100302b
(
  documento character varying(10),
  nit character varying(15),
  id_cliente character varying(10),
  fecha_factura date,
  fecha_vencimiento date,
  valor_factura moneda,
  valor_capital moneda,
  valor_interes moneda,
  id_solicitud character varying(15),
  parcial integer,
  fecha_envio_fiducia timestamp without time zone,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.factura_consorcio20100302b
  OWNER TO postgres;
GRANT ALL ON TABLE con.factura_consorcio20100302b TO postgres;
GRANT SELECT ON TABLE con.factura_consorcio20100302b TO msoto;

