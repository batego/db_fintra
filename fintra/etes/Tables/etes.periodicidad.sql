-- Table: etes.periodicidad

-- DROP TABLE etes.periodicidad;

CREATE TABLE etes.periodicidad
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  descripcion character varying(60) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE etes.periodicidad
  OWNER TO postgres;

