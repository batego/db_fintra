-- Table: opav.sl_hitos

-- DROP TABLE opav.sl_hitos;

CREATE TABLE opav.sl_hitos
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id_solicitud integer NOT NULL,
  nombre text NOT NULL DEFAULT ''::character varying,
  fecha date NOT NULL DEFAULT now(),
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_hitos
  OWNER TO postgres;
