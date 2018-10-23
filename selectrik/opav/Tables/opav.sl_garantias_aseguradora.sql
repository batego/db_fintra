-- Table: opav.sl_garantias_aseguradora

-- DROP TABLE opav.sl_garantias_aseguradora;

CREATE TABLE opav.sl_garantias_aseguradora
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  id_contrato character varying(20) NOT NULL,
  id_garantia integer NOT NULL,
  id_aseguradora integer NOT NULL,
  valor_base numeric(19,3) NOT NULL DEFAULT 0,
  porcentaje_poliza numeric(19,3) NOT NULL DEFAULT 0,
  valor_poliza numeric(19,3) NOT NULL DEFAULT 0,
  porcentaje_aseguradora numeric(19,3) NOT NULL DEFAULT 0,
  valor_aseguradora numeric(19,3) NOT NULL DEFAULT 0,
  cotiz_broker_aceptada character varying(1) NOT NULL DEFAULT 'N'::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  cxp_generada character varying(1) NOT NULL DEFAULT 'N'::character varying,
  cxp_aseguradora character varying(30) NOT NULL DEFAULT ''::character varying,
  id_beneficiario integer,
  secuencia_otro_si integer NOT NULL DEFAULT 0,
  CONSTRAINT sl_garantias_aseguradora_id_contrato_fkey FOREIGN KEY (id_contrato)
      REFERENCES opav.sl_minutas (numero_contrato) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT sl_garantias_aseguradora_id_garantia_fkey FOREIGN KEY (id_garantia)
      REFERENCES opav.sl_minutas_garantias (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_garantias_aseguradora
  OWNER TO postgres;
