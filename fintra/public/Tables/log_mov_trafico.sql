-- Table: log_mov_trafico

-- DROP TABLE log_mov_trafico;

CREATE TABLE log_mov_trafico
(
  reg_status character varying(1) DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  numpla character varying NOT NULL DEFAULT ''::character varying,
  new_observacion text DEFAULT ''::character varying,
  new_tipo_procedencia character varying DEFAULT ''::character varying,
  new_ubicacion_procedencia character varying DEFAULT ''::character varying,
  new_tipo_reporte character varying DEFAULT ''::character varying,
  new_fechareporte timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  last_observacion character varying DEFAULT ''::character varying,
  last_tipo_procedencia character varying DEFAULT ''::character varying,
  last_ubicacion_procedencia character varying DEFAULT ''::character varying,
  last_tipo_reporte character varying DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  last_fechareporte timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  new_zona character varying(5) DEFAULT ''::character varying,
  last_zona character varying(5) DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE log_mov_trafico
  OWNER TO postgres;
GRANT ALL ON TABLE log_mov_trafico TO postgres;
GRANT SELECT ON TABLE log_mov_trafico TO msoto;

