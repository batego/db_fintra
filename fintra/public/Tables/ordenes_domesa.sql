-- Table: ordenes_domesa

-- DROP TABLE ordenes_domesa;

CREATE TABLE ordenes_domesa
(
  no_orden character varying NOT NULL,
  cod_suc character varying,
  beneficiario character varying NOT NULL,
  nombre character varying NOT NULL,
  ced_girador character varying NOT NULL,
  num_cheque character varying NOT NULL,
  cta_girador character varying NOT NULL,
  cod_ent_cheque character varying NOT NULL,
  valor_cheque character varying NOT NULL,
  plaza_cheque character varying NOT NULL,
  cta_consigna character varying NOT NULL,
  nom_consigna character varying NOT NULL,
  num_obl_cheq character varying NOT NULL,
  dir_destino character varying,
  ciud_custod character varying NOT NULL,
  ciudad_girad character varying NOT NULL,
  fec_consigna date NOT NULL,
  fecha_orden date NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE ordenes_domesa
  OWNER TO postgres;
GRANT ALL ON TABLE ordenes_domesa TO postgres;
GRANT SELECT ON TABLE ordenes_domesa TO msoto;

