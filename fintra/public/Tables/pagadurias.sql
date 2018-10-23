-- Table: pagadurias

-- DROP TABLE pagadurias;

CREATE TABLE pagadurias
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  razon_social character varying(300) NOT NULL DEFAULT ''::character varying,
  documento character varying(15) NOT NULL DEFAULT ''::character varying,
  dv character varying(1) NOT NULL DEFAULT ''::character varying,
  municipio character varying(300) NOT NULL DEFAULT ''::character varying,
  direccion character varying(100) NOT NULL DEFAULT ''::character varying,
  telefono character varying(150) NOT NULL DEFAULT ''::character varying,
  correo character varying(70) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE pagadurias
  OWNER TO postgres;
GRANT ALL ON TABLE pagadurias TO postgres;
GRANT SELECT ON TABLE pagadurias TO msoto;

