-- Table: opav.traslado_cxp_contratista

-- DROP TABLE opav.traslado_cxp_contratista;

CREATE TABLE opav.traslado_cxp_contratista
(
  id serial NOT NULL,
  periodo character varying(6) NOT NULL DEFAULT ''::character varying,
  documento character varying(15) NOT NULL DEFAULT ''::character varying,
  concepto character varying(4) NOT NULL DEFAULT ''::character varying,
  proceso character varying(1) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp with time zone,
  user_update character varying(16)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.traslado_cxp_contratista
  OWNER TO postgres;
