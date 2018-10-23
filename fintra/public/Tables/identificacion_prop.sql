-- Table: identificacion_prop

-- DROP TABLE identificacion_prop;

CREATE TABLE identificacion_prop
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  cedula character varying(15) NOT NULL DEFAULT ''::character varying,
  p_nombre character varying(30) NOT NULL DEFAULT ''::character varying,
  s_nombre character varying(30) NOT NULL DEFAULT ''::character varying,
  p_apellido character varying(30) NOT NULL DEFAULT ''::character varying,
  s_apellido character varying(30) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE identificacion_prop
  OWNER TO postgres;
GRANT ALL ON TABLE identificacion_prop TO postgres;
GRANT SELECT ON TABLE identificacion_prop TO msoto;

