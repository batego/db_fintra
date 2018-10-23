-- Table: opav.app_producto_servicio

-- DROP TABLE opav.app_producto_servicio;

CREATE TABLE opav.app_producto_servicio
(
  id serial NOT NULL,
  descripcion character varying(90) NOT NULL DEFAULT ''::character varying,
  prefijo character varying(90) NOT NULL DEFAULT ''::character varying,
  perc_incremento numeric(3,0) DEFAULT 0,
  creation_user character varying(10),
  creation_date timestamp without time zone DEFAULT now(),
  user_update character varying(10),
  last_update timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.app_producto_servicio
  OWNER TO postgres;
