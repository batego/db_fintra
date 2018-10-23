-- Table: historico_pre_aprobados

-- DROP TABLE historico_pre_aprobados;

CREATE TABLE historico_pre_aprobados
(
  idhistorial serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  id_und_negocio integer NOT NULL,
  periodo_lote character varying(6) NOT NULL,
  nit character varying(20) NOT NULL,
  nombre character varying(160) NOT NULL DEFAULT ''::character varying,
  valor_ultimo_credito numeric(12,2) NOT NULL,
  valor_aprobado numeric(12,2) NOT NULL,
  perc_incremento numeric(11,2) DEFAULT 0.0,
  unidad_negocio character varying(30) NOT NULL DEFAULT ''::character varying,
  negocio character varying(15) NOT NULL,
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
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  h_comment text NOT NULL DEFAULT ''::character varying,
  h_last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  h_user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  h_creation_date timestamp without time zone NOT NULL DEFAULT now(),
  h_creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT historico_pre_aprobados_negocio_fkey FOREIGN KEY (negocio)
      REFERENCES negocios (cod_neg) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE historico_pre_aprobados
  OWNER TO postgres;
GRANT ALL ON TABLE historico_pre_aprobados TO postgres;
GRANT SELECT ON TABLE historico_pre_aprobados TO msoto;

