-- Table: opav.sl_especificacion

-- DROP TABLE opav.sl_especificacion;

CREATE TABLE opav.sl_especificacion
(
  id serial NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  nombre text NOT NULL,
  descripcion text DEFAULT ''::character varying,
  tipo_dato character varying(1) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_especificacion
  OWNER TO postgres;
