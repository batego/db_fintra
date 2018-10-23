-- Table: con.traslado_facturas_apoteosys

-- DROP TABLE con.traslado_facturas_apoteosys;

CREATE TABLE con.traslado_facturas_apoteosys
(
  id serial NOT NULL,
  cod_neg character varying,
  tipo_documento character varying,
  documento character varying,
  agencia character varying,
  periodo character varying,
  fecha_negocio date NOT NULL DEFAULT '0099-01-01'::date,
  unidad_negocio character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.traslado_facturas_apoteosys
  OWNER TO postgres;

