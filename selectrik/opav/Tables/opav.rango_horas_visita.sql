-- Table: opav.rango_horas_visita

-- DROP TABLE opav.rango_horas_visita;

CREATE TABLE opav.rango_horas_visita
(
  hora_ini_recibo character varying(5) NOT NULL,
  hora_fin_recibo character varying(5) NOT NULL,
  hora_ini_visita character varying(5) NOT NULL,
  hora_fin_visita character varying(5) NOT NULL,
  dia_suma integer NOT NULL DEFAULT 0,
  reg_status character varying(1) DEFAULT ''::character varying,
  creation_user character varying(10),
  creation_date timestamp without time zone DEFAULT now(),
  user_update character varying(10),
  last_update timestamp without time zone DEFAULT now(),
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.rango_horas_visita
  OWNER TO postgres;
