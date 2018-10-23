-- Table: opav.sl_capitulos_disciplinas

-- DROP TABLE opav.sl_capitulos_disciplinas;

CREATE TABLE opav.sl_capitulos_disciplinas
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id_disciplina_area integer NOT NULL,
  descripcion character varying(300) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_sl_capitulos_disciplinas FOREIGN KEY (id_disciplina_area)
      REFERENCES opav.sl_disciplinas_areas (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_capitulos_disciplinas
  OWNER TO postgres;
