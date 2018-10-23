-- Table: opav.sl_ejecucion_responsables

-- DROP TABLE opav.sl_ejecucion_responsables;

CREATE TABLE opav.sl_ejecucion_responsables
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  id_solicitud integer NOT NULL DEFAULT 0,
  responsable character varying(100) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_ejecucion_responsables
  OWNER TO postgres;
