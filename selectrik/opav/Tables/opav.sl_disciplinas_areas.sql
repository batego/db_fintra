-- Table: opav.sl_disciplinas_areas

-- DROP TABLE opav.sl_disciplinas_areas;

CREATE TABLE opav.sl_disciplinas_areas
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id_area_proyecto integer NOT NULL,
  id_disciplina integer NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_sl_disciplinas FOREIGN KEY (id_disciplina)
      REFERENCES opav.sl_disciplinas (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_sl_disciplinas_area FOREIGN KEY (id_area_proyecto)
      REFERENCES opav.sl_areas_proyecto (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_disciplinas_areas
  OWNER TO postgres;
