-- Table: cr_central_riesgo

-- DROP TABLE cr_central_riesgo;

CREATE TABLE cr_central_riesgo
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  nombre_central_riesgo character varying(30) NOT NULL DEFAULT ''::character varying,
  nombre_corto character varying(30) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cr_central_riesgo
  OWNER TO postgres;
GRANT ALL ON TABLE cr_central_riesgo TO postgres;
GRANT SELECT ON TABLE cr_central_riesgo TO msoto;

