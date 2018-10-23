-- Table: opav.agencias

-- DROP TABLE opav.agencias;

CREATE TABLE opav.agencias
(
  estado character(1) DEFAULT 'A'::bpchar,
  cod_agencia character varying(10) NOT NULL DEFAULT ''::character varying,
  nom_agencia character varying(160) NOT NULL DEFAULT ''::character varying,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT 'COL'::character varying,
  id_cliente_padre character varying(10) DEFAULT ''::character varying,
  nit character varying(15) DEFAULT ''::character varying,
  ciudad character varying(6) NOT NULL DEFAULT ''::character varying,
  direccion character varying(100) NOT NULL DEFAULT ''::character varying,
  telefono character varying(100) NOT NULL DEFAULT ''::character varying,
  nomcontacto character varying(100) NOT NULL DEFAULT ''::character varying,
  telcontacto character varying(100) NOT NULL DEFAULT ''::character varying,
  cel_contacto character varying(50) DEFAULT ''::character varying,
  email_contacto character varying(100) NOT NULL DEFAULT ''::character varying,
  direccion_contacto character varying NOT NULL DEFAULT ''::character varying,
  cargo_contacto character varying(50) DEFAULT ''::character varying,
  cliente_eca character varying(1) DEFAULT 'N'::character varying,
  nombre_representante character varying(160) DEFAULT ''::character varying,
  tel_representante character varying(100) DEFAULT ''::character varying,
  celular_representante character varying(15) DEFAULT ''::character varying,
  email_representante character varying(100) DEFAULT ''::character varying,
  sector character varying(50) DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  tipo_cliente character varying(8) NOT NULL DEFAULT ''::character varying,
  digito_verificacion character varying(1) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.agencias
  OWNER TO postgres;
