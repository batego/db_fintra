-- Table: opav.sl_gestion

-- DROP TABLE opav.sl_gestion;

CREATE TABLE opav.sl_gestion
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id_solicitud integer,
  valor_min numeric(14,2) NOT NULL,
  valor_max numeric(14,2) NOT NULL,
  alerta_min numeric(14,2) NOT NULL,
  alerta_max numeric(14,2) NOT NULL,
  id_indicador integer NOT NULL DEFAULT 0,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_sl_gestion1 FOREIGN KEY (id_indicador)
      REFERENCES opav.sl_indicador (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_gestion
  OWNER TO postgres;
