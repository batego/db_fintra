-- Table: usuario_proyecto

-- DROP TABLE usuario_proyecto;

CREATE TABLE usuario_proyecto
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(40) NOT NULL DEFAULT ''::character varying,
  login character varying(12) NOT NULL DEFAULT ''::character varying,
  project character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  base_datos character varying(25)
)
WITH (
  OIDS=TRUE
);
ALTER TABLE usuario_proyecto
  OWNER TO postgres;
GRANT ALL ON TABLE usuario_proyecto TO postgres;
GRANT SELECT ON TABLE usuario_proyecto TO msoto;

