-- Table: estacion_gasolina

-- DROP TABLE estacion_gasolina;

CREATE TABLE estacion_gasolina
(
  nit character varying(15) NOT NULL DEFAULT ''::character varying,
  tel character varying(50) DEFAULT ''::character varying,
  dir character varying(100) DEFAULT ''::character varying,
  id_responsable character varying(15) DEFAULT ''::character varying,
  nombre_responsable character varying(100) DEFAULT ''::character varying,
  tipo_id_responsable character varying(3) DEFAULT ''::character varying,
  mail character varying(100) DEFAULT ''::character varying,
  descuento numeric(5,2) DEFAULT 0,
  reg_status character varying DEFAULT ''::character varying,
  codciu character varying(50) DEFAULT ''::character varying,
  country_code character varying(2) DEFAULT ''::character varying,
  nombre_estacion character varying(150) NOT NULL DEFAULT ''::character varying,
  login character varying(20) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone DEFAULT now(),
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE estacion_gasolina
  OWNER TO postgres;
GRANT ALL ON TABLE estacion_gasolina TO postgres;
GRANT SELECT ON TABLE estacion_gasolina TO blackberry;
GRANT SELECT ON TABLE estacion_gasolina TO msoto;

