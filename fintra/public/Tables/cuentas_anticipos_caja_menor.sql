-- Table: cuentas_anticipos_caja_menor

-- DROP TABLE cuentas_anticipos_caja_menor;

CREATE TABLE cuentas_anticipos_caja_menor
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(6) NOT NULL DEFAULT 'FINV'::character varying,
  nombre_cuenta character varying(50) NOT NULL DEFAULT ''::character varying,
  cuenta character varying(25) NOT NULL DEFAULT ''::character varying,
  hc character varying(6) NOT NULL DEFAULT ''::character varying,
  descripcion_hc character varying(200) NOT NULL DEFAULT ''::character varying,
  tipo_documento character varying(6) NOT NULL DEFAULT ''::character varying,
  concepto character varying NOT NULL DEFAULT ''::character varying,
  legalizar character varying(1) NOT NULL DEFAULT 'N'::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(15) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cuentas_anticipos_caja_menor
  OWNER TO postgres;
GRANT ALL ON TABLE cuentas_anticipos_caja_menor TO postgres;
GRANT SELECT ON TABLE cuentas_anticipos_caja_menor TO msoto;

