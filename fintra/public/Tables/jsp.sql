-- Table: jsp

-- DROP TABLE jsp;

CREATE TABLE jsp
(
  codigo character varying(50) NOT NULL DEFAULT ''::character varying,
  nombre character varying(100) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(100) NOT NULL DEFAULT ''::character varying,
  ruta character varying(100) NOT NULL DEFAULT ''::character varying,
  rec_status character varying(1) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT (now())::timestamp without time zone,
  user_update character varying NOT NULL DEFAULT ''::character varying,
  cia character varying(15) NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT (now())::timestamp without time zone,
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE jsp
  OWNER TO postgres;
GRANT ALL ON TABLE jsp TO postgres;
GRANT SELECT ON TABLE jsp TO msoto;

