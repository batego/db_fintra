-- Table: perfil_trf

-- DROP TABLE perfil_trf;

CREATE TABLE perfil_trf
(
  id_perfil character varying(12) NOT NULL,
  nombre character varying(60) NOT NULL DEFAULT ''::character varying,
  rec_status character varying(1) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT (now())::timestamp without time zone,
  user_update character varying NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT (now())::timestamp without time zone,
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE perfil_trf
  OWNER TO postgres;
GRANT ALL ON TABLE perfil_trf TO postgres;
GRANT SELECT ON TABLE perfil_trf TO msoto;

