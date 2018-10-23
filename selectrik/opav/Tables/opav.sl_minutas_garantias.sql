-- Table: opav.sl_minutas_garantias

-- DROP TABLE opav.sl_minutas_garantias;

CREATE TABLE opav.sl_minutas_garantias
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  id_contrato character varying(20) NOT NULL,
  id_poliza integer NOT NULL,
  tipo_entrada integer NOT NULL DEFAULT 0,
  valor_base numeric(19,3) NOT NULL DEFAULT 0,
  porcentaje_poliza numeric(19,3) NOT NULL DEFAULT 0,
  valor_poliza numeric(19,3) NOT NULL DEFAULT 0,
  vigencia_poliza integer NOT NULL DEFAULT 0,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  id_beneficiario integer,
  id_causal integer,
  extracontractual character varying(1) NOT NULL DEFAULT 'N'::character varying,
  otro_si character varying(1) NOT NULL DEFAULT 'N'::character varying,
  secuencia_otro_si integer NOT NULL DEFAULT 0,
  CONSTRAINT sl_minutas_garantias_id_contrato_fkey FOREIGN KEY (id_contrato)
      REFERENCES opav.sl_minutas (numero_contrato) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_minutas_garantias
  OWNER TO postgres;
