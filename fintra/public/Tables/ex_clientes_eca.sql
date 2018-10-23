-- Table: ex_clientes_eca

-- DROP TABLE ex_clientes_eca;

CREATE TABLE ex_clientes_eca
(
  id_cliente character varying(10) NOT NULL DEFAULT ''::character varying,
  nit character varying(15) DEFAULT ''::character varying,
  nombre character varying(160) DEFAULT ''::character varying,
  nombre_contacto character varying DEFAULT ''::character varying,
  tel1 character varying(50) DEFAULT ''::character varying,
  tel2 character varying(50) DEFAULT ''::character varying,
  tipo character varying(2) DEFAULT ''::character varying, -- regulado o no regulado
  departamento character varying(50) DEFAULT ''::character varying,
  ciudad character varying(50) DEFAULT ''::character varying,
  direccion character varying(60) DEFAULT ''::character varying,
  sector character varying(50) DEFAULT ''::character varying,
  nombre_representante character varying(160) DEFAULT ''::character varying,
  cargo_contacto character varying DEFAULT ''::character varying,
  tel_representante character varying(50) DEFAULT ''::character varying,
  celular_representante character varying(15) DEFAULT ''::character varying,
  last_update timestamp without time zone DEFAULT now(),
  creation_date timestamp without time zone DEFAULT now(),
  user_update character varying(10) DEFAULT ''::character varying,
  creation_user character varying(10) DEFAULT ''::character varying,
  id_ejecutivo character varying(10) DEFAULT ''::character varying,
  reg_status character varying(1) DEFAULT ''::character varying,
  esoficial character varying(1) DEFAULT 'N'::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE ex_clientes_eca
  OWNER TO postgres;
GRANT ALL ON TABLE ex_clientes_eca TO postgres;
GRANT SELECT ON TABLE ex_clientes_eca TO msoto;
COMMENT ON COLUMN ex_clientes_eca.tipo IS 'regulado o no regulado';


