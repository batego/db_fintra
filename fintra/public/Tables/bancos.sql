-- Table: bancos

-- DROP TABLE bancos;

CREATE TABLE bancos
(
  dstrct character varying NOT NULL DEFAULT 'FINV'::character varying,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  codigo character varying(6) NOT NULL DEFAULT ''::character varying,
  nombre character varying(45) NOT NULL DEFAULT ''::character varying,
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT '2010-09-07 08:47:58.031'::timestamp without time zone,
  user_update character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  nit character varying(15) NOT NULL DEFAULT ''::character varying,
  base_ano integer NOT NULL DEFAULT 360, -- Numero de dias que el banco toma como base para un año
  dia integer NOT NULL DEFAULT 28
)
WITH (
  OIDS=FALSE
);
ALTER TABLE bancos
  OWNER TO postgres;
GRANT ALL ON TABLE bancos TO postgres;
GRANT SELECT ON TABLE bancos TO msoto;
COMMENT ON TABLE bancos
  IS 'Codificación estándar de bancos';
COMMENT ON COLUMN bancos.base_ano IS 'Numero de dias que el banco toma como base para un año';


