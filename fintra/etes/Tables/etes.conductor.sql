-- Table: etes.conductor

-- DROP TABLE etes.conductor;

CREATE TABLE etes.conductor
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  cod_proveedor character varying(30) NOT NULL DEFAULT ''::character varying,
  nombre character varying(100) NOT NULL DEFAULT ''::character varying,
  banco character varying(100) NOT NULL DEFAULT ''::character varying,
  sucursal character varying(100) NOT NULL DEFAULT ''::character varying,
  cedula_titular_cuenta character varying(100) NOT NULL DEFAULT ''::character varying,
  nombre_titular_cuenta character varying(200) NOT NULL DEFAULT ''::character varying,
  tipo_cuenta character varying(50) NOT NULL DEFAULT ''::character varying,
  no_cuenta character varying(100) NOT NULL DEFAULT ''::character varying,
  direccion character varying(100) NOT NULL DEFAULT ''::character varying,
  veto character varying(1) NOT NULL DEFAULT 'N'::character varying,
  veto_causal character varying(300) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT conductor_cod_proveedor_check CHECK (cod_proveedor::text <> ''::text AND cod_proveedor::text <> ' '::text AND cod_proveedor::text <> '  '::text),
  CONSTRAINT conductor_nombre_check CHECK (nombre::text <> ''::text AND nombre::text <> ' '::text AND nombre::text <> '  '::text)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE etes.conductor
  OWNER TO postgres;

