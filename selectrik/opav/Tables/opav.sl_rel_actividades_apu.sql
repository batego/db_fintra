-- Table: opav.sl_rel_actividades_apu

-- DROP TABLE opav.sl_rel_actividades_apu;

CREATE TABLE opav.sl_rel_actividades_apu
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id_actividad_capitulo integer NOT NULL,
  id_apu integer NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  cantidad numeric NOT NULL DEFAULT 0,
  estado integer NOT NULL DEFAULT 0,
  posicion integer NOT NULL DEFAULT 0,
  CONSTRAINT fk_sl_apu FOREIGN KEY (id_apu)
      REFERENCES opav.sl_apu (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_sl_rel_actividades_apu FOREIGN KEY (id_actividad_capitulo)
      REFERENCES opav.sl_actividades_capitulos (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_rel_actividades_apu
  OWNER TO postgres;
