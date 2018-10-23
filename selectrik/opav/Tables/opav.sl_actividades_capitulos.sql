-- Table: opav.sl_actividades_capitulos

-- DROP TABLE opav.sl_actividades_capitulos;

CREATE TABLE opav.sl_actividades_capitulos
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id_capitulo integer NOT NULL,
  id_actividad integer NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_sl_actividades FOREIGN KEY (id_actividad)
      REFERENCES opav.sl_actividades (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_sl_actividades_capitulos FOREIGN KEY (id_capitulo)
      REFERENCES opav.sl_capitulos_disciplinas (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_actividades_capitulos
  OWNER TO postgres;
