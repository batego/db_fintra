-- Table: configuracion_factor_por_millon

-- DROP TABLE configuracion_factor_por_millon;

CREATE TABLE configuracion_factor_por_millon
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  numero_convenio character varying(5) NOT NULL DEFAULT ''::character varying,
  id_unidad_negocio integer,
  nit_empresa character varying(15) NOT NULL DEFAULT ''::character varying,
  plazo_inicial integer NOT NULL,
  plazo_final integer NOT NULL,
  porcentaje_comision numeric(11,3) NOT NULL DEFAULT 0,
  valor_comision numeric(19,3) NOT NULL DEFAULT 0,
  porcentaje_iva numeric(11,3) NOT NULL DEFAULT 0,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  financiado character varying(1) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT configuracion_factor_por_millon_empresa_fkey FOREIGN KEY (nit_empresa)
      REFERENCES rel_proveedores_fianza (nit) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT configuracion_factor_por_millon_fkey FOREIGN KEY (id_unidad_negocio)
      REFERENCES unidad_negocio (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE configuracion_factor_por_millon
  OWNER TO postgres;

