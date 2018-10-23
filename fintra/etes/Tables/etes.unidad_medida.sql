-- Table: etes.unidad_medida

-- DROP TABLE etes.unidad_medida;

CREATE TABLE etes.unidad_medida
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  nombre_unidad character varying(100) NOT NULL DEFAULT ''::character varying,
  unidad_medicion numeric(5,2) DEFAULT (0)::numeric
)
WITH (
  OIDS=FALSE
);
ALTER TABLE etes.unidad_medida
  OWNER TO postgres;

