-- Table: perfilopcion_trf

-- DROP TABLE perfilopcion_trf;

CREATE TABLE perfilopcion_trf
(
  id_perfil character varying(12) NOT NULL,
  id_opcion numeric(8,0) NOT NULL,
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
ALTER TABLE perfilopcion_trf
  OWNER TO postgres;
GRANT ALL ON TABLE perfilopcion_trf TO postgres;

