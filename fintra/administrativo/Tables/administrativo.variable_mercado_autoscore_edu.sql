-- Table: administrativo.variable_mercado_autoscore_edu

-- DROP TABLE administrativo.variable_mercado_autoscore_edu;

CREATE TABLE administrativo.variable_mercado_autoscore_edu
(
  id serial NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  variable_buro text NOT NULL,
  control_variable character varying(1) NOT NULL DEFAULT 'N'::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.variable_mercado_autoscore_edu
  OWNER TO postgres;

