-- Table: opav.sl_rel_cargo_carga_laboral

-- DROP TABLE opav.sl_rel_cargo_carga_laboral;

CREATE TABLE opav.sl_rel_cargo_carga_laboral
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id_cargos integer,
  id_carga_laboral integer,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now()
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_rel_cargo_carga_laboral
  OWNER TO postgres;
