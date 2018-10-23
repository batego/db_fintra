-- Table: control_actualizaciones

-- DROP TABLE control_actualizaciones;

CREATE TABLE control_actualizaciones
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  comando text NOT NULL DEFAULT ''::character varying,
  fecha_procesado timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  base_proceso character varying(5) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE control_actualizaciones
  OWNER TO postgres;
GRANT ALL ON TABLE control_actualizaciones TO postgres;
GRANT SELECT ON TABLE control_actualizaciones TO msoto;

