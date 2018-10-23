-- Table: opav.sl_garantias_otros_costos

-- DROP TABLE opav.sl_garantias_otros_costos;

CREATE TABLE opav.sl_garantias_otros_costos
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  id_contrato character varying(20) NOT NULL,
  id_aseguradora integer NOT NULL,
  valor_otros_gastos numeric(19,2) NOT NULL DEFAULT 0,
  porcentaje_iva numeric(19,2) NOT NULL DEFAULT 0,
  valor_iva numeric(19,2) NOT NULL DEFAULT 0,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  id_beneficiario integer NOT NULL DEFAULT 1,
  secuencia integer NOT NULL DEFAULT 0,
  CONSTRAINT sl_garantias_otros_costos_id_contrato_fkey FOREIGN KEY (id_contrato)
      REFERENCES opav.sl_minutas (numero_contrato) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_garantias_otros_costos
  OWNER TO postgres;
