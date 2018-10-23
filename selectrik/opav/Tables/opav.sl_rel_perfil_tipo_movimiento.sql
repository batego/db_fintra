-- Table: opav.sl_rel_perfil_tipo_movimiento

-- DROP TABLE opav.sl_rel_perfil_tipo_movimiento;

CREATE TABLE opav.sl_rel_perfil_tipo_movimiento
(
  id serial NOT NULL,
  id_perfil integer,
  id_tipo_moviento integer,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_rel_perfil_tipo_movimiento
  OWNER TO postgres;
