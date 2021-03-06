-- Table: opav.sl_procedencia_variables_conf_docs

-- DROP TABLE opav.sl_procedencia_variables_conf_docs;

CREATE TABLE opav.sl_procedencia_variables_conf_docs
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  tabla_base character varying(30) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(150) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_procedencia_variables_conf_docs
  OWNER TO postgres;
