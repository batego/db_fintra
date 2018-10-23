-- Table: ex_historico_clientes_eca

-- DROP TABLE ex_historico_clientes_eca;

CREATE TABLE ex_historico_clientes_eca
(
  id_cliente character varying(10),
  nit character varying(15),
  nombre character varying(160),
  nombre_contacto character varying,
  tel1 character varying(50),
  tel2 character varying(50),
  tipo character varying(2),
  departamento character varying(50),
  ciudad character varying(50),
  direccion character varying(60),
  sector character varying(50),
  nombre_representante character varying(160),
  cargo_contacto character varying,
  tel_representante character varying(50),
  celular_representante character varying(15),
  last_update timestamp without time zone,
  creation_date timestamp without time zone,
  user_update character varying(10),
  creation_user character varying(10),
  id_ejecutivo character varying(10),
  reg_status character varying(1),
  id_h integer NOT NULL DEFAULT nextval('historico_clientes_eca_id_h_seq'::regclass),
  hcreation_date timestamp without time zone,
  esoficial character varying(1) DEFAULT 'N'::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE ex_historico_clientes_eca
  OWNER TO postgres;
GRANT ALL ON TABLE ex_historico_clientes_eca TO postgres;
GRANT SELECT ON TABLE ex_historico_clientes_eca TO msoto;

