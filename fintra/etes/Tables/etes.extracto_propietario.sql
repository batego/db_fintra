-- Table: etes.extracto_propietario

-- DROP TABLE etes.extracto_propietario;

CREATE TABLE etes.extracto_propietario
(
  id serial NOT NULL,
  num_venta character varying(80),
  planilla character varying(80),
  cedula character varying(80),
  placa character varying(80),
  valor_venta numeric(11,2)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE etes.extracto_propietario
  OWNER TO postgres;

