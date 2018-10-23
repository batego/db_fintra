-- Table: opav.sl_rel_cargo_actividad_planeacion

-- DROP TABLE opav.sl_rel_cargo_actividad_planeacion;

CREATE TABLE opav.sl_rel_cargo_actividad_planeacion
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id_cargos integer,
  id_actividad_planeacion integer,
  peso numeric(6,2) NOT NULL DEFAULT 0,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now()
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_rel_cargo_actividad_planeacion
  OWNER TO postgres;
