-- Table: datos_transferencias_inversionistas

-- DROP TABLE datos_transferencias_inversionistas;

CREATE TABLE datos_transferencias_inversionistas
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL,
  tipo_transferencia character varying(1) NOT NULL DEFAULT ''::character varying,
  nit character varying(15) NOT NULL,
  cuenta character varying(30) NOT NULL DEFAULT ''::character varying,
  banco character varying(30) NOT NULL DEFAULT ''::character varying,
  titular_cuenta character varying(50) DEFAULT ''::character varying,
  nit_cuenta character varying(20) DEFAULT ''::character varying,
  tipo_cuenta character varying(2) DEFAULT ''::character varying,
  nit_beneficiario character varying(20) NOT NULL DEFAULT ''::character varying,
  nombre_beneficiario character varying(100) DEFAULT ''::character varying,
  cheque_cruzado character varying(1) DEFAULT ''::character varying,
  cheque_primer_beneficiario character varying(1) DEFAULT ''::character varying,
  creation_date timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  concepto_transaccion character varying(200) DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE datos_transferencias_inversionistas
  OWNER TO postgres;
GRANT ALL ON TABLE datos_transferencias_inversionistas TO postgres;
GRANT SELECT ON TABLE datos_transferencias_inversionistas TO msoto;

