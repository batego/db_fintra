-- Table: opav.sl_apu

-- DROP TABLE opav.sl_apu;

CREATE TABLE opav.sl_apu
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  nombre text NOT NULL DEFAULT ''::character varying,
  id_unidad_medida integer NOT NULL DEFAULT 0,
  nits_propietario text DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  tipo_apu character varying(8) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_apu
  OWNER TO postgres;
