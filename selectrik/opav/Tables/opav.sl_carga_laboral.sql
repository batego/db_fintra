-- Table: opav.sl_carga_laboral

-- DROP TABLE opav.sl_carga_laboral;

CREATE TABLE opav.sl_carga_laboral
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id_actividad_planeacion integer NOT NULL,
  nivel character varying(10) NOT NULL DEFAULT ''::character varying,
  rango_ini numeric(13,2) NOT NULL DEFAULT 0,
  rango_fin numeric(13,2) NOT NULL DEFAULT 0,
  id_unidad_medida_general integer,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_carga_laboral
  OWNER TO postgres;
