-- Table: administrativo.proceso_endoso

-- DROP TABLE administrativo.proceso_endoso;

CREATE TABLE administrativo.proceso_endoso
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(6) NOT NULL DEFAULT 'FINV'::character varying,
  nombre_proceso character varying(200) NOT NULL DEFAULT ''::character varying,
  custodiada_por character varying(20) NOT NULL DEFAULT ''::character varying,
  nombre_custodiador character varying(50) NOT NULL DEFAULT ''::character varying,
  cuenta_cabecera_cdiar character varying(25) NOT NULL DEFAULT ''::character varying,
  cmc_to_facturas character varying(6) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(15) NOT NULL DEFAULT ''::character varying,
  concepto character varying(50) DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.proceso_endoso
  OWNER TO postgres;

