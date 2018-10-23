-- Table: codigos_ciudad_dane

-- DROP TABLE codigos_ciudad_dane;

CREATE TABLE codigos_ciudad_dane
(
  id serial NOT NULL,
  cod_dep character(30) NOT NULL,
  nom_dep character(30) NOT NULL,
  cod_mun character(30) NOT NULL,
  nom_mun character(30) NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE codigos_ciudad_dane
  OWNER TO postgres;
GRANT ALL ON TABLE codigos_ciudad_dane TO postgres;
GRANT SELECT ON TABLE codigos_ciudad_dane TO msoto;

