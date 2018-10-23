-- Table: perfilopcion

-- DROP TABLE perfilopcion;

CREATE TABLE perfilopcion
(
  id_perfil numeric(12,0),
  id_opcion numeric(12,0),
  id_padre numeric(12,0),
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE perfilopcion
  OWNER TO postgres;
GRANT ALL ON TABLE perfilopcion TO postgres;
GRANT SELECT ON TABLE perfilopcion TO msoto;

