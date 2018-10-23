-- Table: administrativo.copia_historico_deducciones_fianza

-- DROP TABLE administrativo.copia_historico_deducciones_fianza;

CREATE TABLE administrativo.copia_historico_deducciones_fianza
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(6) NOT NULL DEFAULT 'FINV'::character varying,
  periodo_corte character varying(6) NOT NULL DEFAULT ''::character varying,
  nit_empresa_fianza character varying(15) NOT NULL DEFAULT ''::character varying,
  nit_cliente character varying(20) NOT NULL DEFAULT ''::character varying,
  documento_relacionado character varying(20) NOT NULL DEFAULT ''::character varying,
  negocio character varying(15) NOT NULL DEFAULT ''::character varying,
  plazo character varying(20) NOT NULL DEFAULT ''::character varying,
  valor_negocio numeric(19,2) NOT NULL DEFAULT 0.00,
  valor_desembolsado numeric(19,2) NOT NULL DEFAULT 0.00,
  subtotal_fianza numeric(19,2) NOT NULL DEFAULT 0.00,
  valor_iva numeric(19,2) NOT NULL DEFAULT 0.00,
  valor_fianza numeric(19,2) NOT NULL DEFAULT 0.00,
  fecha_vencimiento timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  id_unidad_negocio integer NOT NULL DEFAULT 0,
  id_convenio integer NOT NULL DEFAULT 0,
  estado_proceso character varying(2) NOT NULL DEFAULT ''::character varying,
  documento_cxp character varying(20) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(15) NOT NULL DEFAULT ''::character varying,
  agencia character varying(15) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT copia_historico_deducciones_fianza_empresa_fkey FOREIGN KEY (nit_empresa_fianza)
      REFERENCES rel_proveedores_fianza (nit) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.copia_historico_deducciones_fianza
  OWNER TO postgres;

