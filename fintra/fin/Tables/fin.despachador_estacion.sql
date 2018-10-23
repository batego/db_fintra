-- Table: fin.despachador_estacion

-- DROP TABLE fin.despachador_estacion;

CREATE TABLE fin.despachador_estacion
(
  despachador character varying(10) NOT NULL DEFAULT ''::character varying,
  estacion character varying(10) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fin.despachador_estacion
  OWNER TO postgres;

