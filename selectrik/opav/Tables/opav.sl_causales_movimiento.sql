-- Table: opav.sl_causales_movimiento

-- DROP TABLE opav.sl_causales_movimiento;

CREATE TABLE opav.sl_causales_movimiento
(
  id serial NOT NULL,
  id_tipo_movimiento integer NOT NULL DEFAULT 0,
  nombre text NOT NULL DEFAULT ''::character varying,
  descripcion text NOT NULL DEFAULT ''::character varying,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_causales_movimiento
  OWNER TO postgres;
