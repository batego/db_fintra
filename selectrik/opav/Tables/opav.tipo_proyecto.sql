-- Table: opav.tipo_proyecto

-- DROP TABLE opav.tipo_proyecto;

CREATE TABLE opav.tipo_proyecto
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  cod_proyecto character varying(8) NOT NULL,
  descripcion character varying(50) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.tipo_proyecto
  OWNER TO postgres;
