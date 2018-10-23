-- Table: con.configuracion_cuentas_dinamica_contable

-- DROP TABLE con.configuracion_cuentas_dinamica_contable;

CREATE TABLE con.configuracion_cuentas_dinamica_contable
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT 'FINV'::character varying,
  cuenta character varying(20) NOT NULL DEFAULT ''::character varying,
  nombre_cuenta character varying(150) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  modulo character varying(120) NOT NULL DEFAULT ''::character varying,
  paso character varying(10) NOT NULL DEFAULT ''::character varying,
  clasificacion character varying(150) NOT NULL DEFAULT ''::character varying,
  visualizar character varying(1) NOT NULL DEFAULT 'N'::character varying,
  tipo_documento text NOT NULL DEFAULT ''::text
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.configuracion_cuentas_dinamica_contable
  OWNER TO postgres;
GRANT ALL ON TABLE con.configuracion_cuentas_dinamica_contable TO postgres;
GRANT SELECT ON TABLE con.configuracion_cuentas_dinamica_contable TO msoto;

