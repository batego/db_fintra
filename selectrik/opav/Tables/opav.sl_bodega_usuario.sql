-- Table: opav.sl_bodega_usuario

-- DROP TABLE opav.sl_bodega_usuario;

CREATE TABLE opav.sl_bodega_usuario
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  id_bodega numeric NOT NULL,
  id_usuario character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_bodega_usuario
  OWNER TO postgres;
