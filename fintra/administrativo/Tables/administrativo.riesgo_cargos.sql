-- Table: administrativo.riesgo_cargos

-- DROP TABLE administrativo.riesgo_cargos;

CREATE TABLE administrativo.riesgo_cargos
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  intensidad character varying(200),
  codigo character varying NOT NULL,
  porcentaje numeric,
  actividades character varying(500),
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(15) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.riesgo_cargos
  OWNER TO postgres;

