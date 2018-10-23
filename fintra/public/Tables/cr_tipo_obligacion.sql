-- Table: cr_tipo_obligacion

-- DROP TABLE cr_tipo_obligacion;

CREATE TABLE cr_tipo_obligacion
(
  id serial NOT NULL,
  id_central_riesgo integer NOT NULL,
  cod character varying(2) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(30) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cr_tipo_obligacion
  OWNER TO postgres;
GRANT ALL ON TABLE cr_tipo_obligacion TO postgres;
GRANT SELECT ON TABLE cr_tipo_obligacion TO msoto;

