-- Table: excepciones_condonacion

-- DROP TABLE excepciones_condonacion;

CREATE TABLE excepciones_condonacion
(
  id serial NOT NULL,
  periodo_condonacion character varying(6) NOT NULL DEFAULT ''::character varying,
  negocio character varying(11) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE excepciones_condonacion
  OWNER TO postgres;
GRANT ALL ON TABLE excepciones_condonacion TO postgres;
GRANT SELECT ON TABLE excepciones_condonacion TO msoto;

