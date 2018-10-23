-- Table: con.mapa_cuentas_fintra

-- DROP TABLE con.mapa_cuentas_fintra;

CREATE TABLE con.mapa_cuentas_fintra
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(6) NOT NULL DEFAULT 'FINV'::character varying,
  bd_local character varying(20) NOT NULL DEFAULT ''::character varying,
  tipo_doc_local character varying(50) NOT NULL DEFAULT ''::character varying,
  cuenta_local character varying(50) NOT NULL DEFAULT ''::character varying,
  cmc_local character varying(50) NOT NULL DEFAULT ''::character varying,
  bd_remota character varying(20) NOT NULL DEFAULT ''::character varying,
  cuenta_remota character varying(50) NOT NULL DEFAULT ''::character varying,
  cmc_remoto character varying(50) NOT NULL DEFAULT ''::character varying,
  tipo_doc_remoto character varying(50) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(50) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(15) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.mapa_cuentas_fintra
  OWNER TO postgres;
GRANT ALL ON TABLE con.mapa_cuentas_fintra TO postgres;
GRANT SELECT ON TABLE con.mapa_cuentas_fintra TO msoto;

