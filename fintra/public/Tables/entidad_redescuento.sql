-- Table: entidad_redescuento

-- DROP TABLE entidad_redescuento;

CREATE TABLE entidad_redescuento
(
  id serial NOT NULL,
  nombre character varying(30) NOT NULL,
  descripcion character varying(50),
  fenalco boolean NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE entidad_redescuento
  OWNER TO postgres;
GRANT ALL ON TABLE entidad_redescuento TO postgres;
GRANT SELECT ON TABLE entidad_redescuento TO msoto;

