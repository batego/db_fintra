-- Table: empresa_mensajeria

-- DROP TABLE empresa_mensajeria;

CREATE TABLE empresa_mensajeria
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT 'FINV'::character varying,
  nombre_empresa character varying NOT NULL DEFAULT ''::character varying,
  nit integer NOT NULL DEFAULT 0,
  direccion character varying NOT NULL DEFAULT ''::character varying,
  telefono character varying NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE empresa_mensajeria
  OWNER TO postgres;
GRANT ALL ON TABLE empresa_mensajeria TO postgres;
GRANT SELECT ON TABLE empresa_mensajeria TO msoto;

