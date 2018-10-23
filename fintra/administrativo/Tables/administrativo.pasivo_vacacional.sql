-- Table: administrativo.pasivo_vacacional

-- DROP TABLE administrativo.pasivo_vacacional;

CREATE TABLE administrativo.pasivo_vacacional
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  cc_empleado character varying(15) NOT NULL DEFAULT ''::character varying,
  periodo_ini timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  periodo_fin timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  saldo_inicial integer DEFAULT 0,
  dias_disfrutados integer DEFAULT 0,
  dias_compensados integer DEFAULT 0,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.pasivo_vacacional
  OWNER TO postgres;

