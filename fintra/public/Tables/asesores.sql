-- Table: asesores

-- DROP TABLE asesores;

CREATE TABLE asesores
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(6) NOT NULL DEFAULT ''::character varying,
  idusuario character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(15) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE asesores
  OWNER TO postgres;
GRANT ALL ON TABLE asesores TO postgres;
GRANT SELECT ON TABLE asesores TO msoto;

