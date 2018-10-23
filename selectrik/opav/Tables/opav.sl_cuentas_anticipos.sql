-- Table: opav.sl_cuentas_anticipos

-- DROP TABLE opav.sl_cuentas_anticipos;

CREATE TABLE opav.sl_cuentas_anticipos
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(6) NOT NULL DEFAULT 'FINV'::character varying,
  nombre_cuenta character varying(50) NOT NULL DEFAULT ''::character varying,
  cuenta character varying(25) NOT NULL DEFAULT ''::character varying,
  hc character varying(6) NOT NULL DEFAULT ''::character varying,
  descripcion_hc character varying(200) NOT NULL DEFAULT ''::character varying,
  tipo_documento character varying(6) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(15) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_cuentas_anticipos
  OWNER TO postgres;
