-- Table: business_intelligence.consolidado_nomina_fintra_cobranza

-- DROP TABLE business_intelligence.consolidado_nomina_fintra_cobranza;

CREATE TABLE business_intelligence.consolidado_nomina_fintra_cobranza
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT 'FINV'::character varying,
  anio character varying(4) NOT NULL DEFAULT ''::character varying,
  periodo character varying(6) NOT NULL DEFAULT ''::character varying,
  cuenta character varying(30) NOT NULL DEFAULT ''::character varying,
  tipo_documento character varying(5) NOT NULL DEFAULT ''::character varying,
  detalle text NOT NULL DEFAULT ''::character varying,
  clasificacion character varying(150) NOT NULL DEFAULT ''::character varying,
  nit_empleado character varying(15) NOT NULL DEFAULT ''::character varying,
  nombre_empleado text DEFAULT ''::character varying,
  valor_debito numeric,
  valor_credito numeric,
  empresa character varying(20) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE business_intelligence.consolidado_nomina_fintra_cobranza
  OWNER TO postgres;

