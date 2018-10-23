-- Table: documentos_requeridos_fintracredit

-- DROP TABLE documentos_requeridos_fintracredit;

CREATE TABLE documentos_requeridos_fintracredit
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(300) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE documentos_requeridos_fintracredit
  OWNER TO postgres;
GRANT ALL ON TABLE documentos_requeridos_fintracredit TO postgres;
GRANT SELECT ON TABLE documentos_requeridos_fintracredit TO msoto;

