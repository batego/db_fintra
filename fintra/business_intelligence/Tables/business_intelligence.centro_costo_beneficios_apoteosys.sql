-- Table: business_intelligence.centro_costo_beneficios_apoteosys

-- DROP TABLE business_intelligence.centro_costo_beneficios_apoteosys;

CREATE TABLE business_intelligence.centro_costo_beneficios_apoteosys
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(6) NOT NULL DEFAULT 'FINV'::character varying,
  id serial NOT NULL,
  master_orden integer,
  orden integer NOT NULL,
  nivel_1 text NOT NULL DEFAULT ''::character varying,
  nivel_2 text NOT NULL DEFAULT ''::character varying,
  nivel_3 text NOT NULL DEFAULT ''::character varying,
  nivel_4 text NOT NULL DEFAULT ''::character varying,
  nom_cuenta character varying(150) NOT NULL DEFAULT ''::character varying,
  cuenta_contable character varying(15) NOT NULL DEFAULT ''::character varying,
  centro_costo character varying(20) NOT NULL DEFAULT ''::character varying,
  unidad character varying(50) NOT NULL DEFAULT ''::character varying,
  producto character varying(150) NOT NULL DEFAULT ''::character varying,
  clasificacion character varying(100) NOT NULL DEFAULT ''::character varying,
  empresa character varying(100) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(15) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE business_intelligence.centro_costo_beneficios_apoteosys
  OWNER TO postgres;

