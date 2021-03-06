-- Table: opav.sl_oc_excluidas_migracion_2017_2018

-- DROP TABLE opav.sl_oc_excluidas_migracion_2017_2018;

CREATE TABLE opav.sl_oc_excluidas_migracion_2017_2018
(
  id serial NOT NULL,
  orden_compra character varying(15) NOT NULL DEFAULT ''::character varying,
  motivo text NOT NULL DEFAULT ''::character varying,
  responsable character varying(20) NOT NULL DEFAULT ''::character varying,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_oc_excluidas_migracion_2017_2018
  OWNER TO postgres;
