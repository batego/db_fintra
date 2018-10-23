-- Table: pre_aprobados

-- DROP TABLE pre_aprobados;

CREATE TABLE pre_aprobados
(
  id_und_negocio integer NOT NULL,
  nit character varying(20) NOT NULL DEFAULT ''::character varying,
  nombre character varying(160) NOT NULL DEFAULT ''::character varying,
  valor_ultimo_credito numeric(20,2) NOT NULL,
  valor_aprobado numeric(20,2) NOT NULL,
  perc_incremento numeric(11,2) DEFAULT 0.0,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  unidad_negocio character varying(30) NOT NULL DEFAULT ''::character varying,
  negocio character varying(15) DEFAULT ''::character varying,
  nombre_afiliado character varying(160) NOT NULL DEFAULT ''::character varying,
  fecha_desembolso date NOT NULL,
  periodo_desembolso character varying(10) NOT NULL DEFAULT ''::character varying,
  fecha_vencimiento date NOT NULL,
  depto character varying(40) NOT NULL DEFAULT ''::character varying,
  ciudad character varying(40) NOT NULL DEFAULT ''::character varying,
  direccion character varying(160) NOT NULL DEFAULT ''::character varying,
  barrio character varying(50) NOT NULL DEFAULT ''::character varying,
  telefono character varying(50) NOT NULL DEFAULT ''::character varying,
  valor_saldo numeric(15,2) DEFAULT 0.0,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE pre_aprobados
  OWNER TO postgres;
GRANT ALL ON TABLE pre_aprobados TO postgres;
GRANT SELECT ON TABLE pre_aprobados TO msoto;

