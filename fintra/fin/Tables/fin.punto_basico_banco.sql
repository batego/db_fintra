-- Table: fin.punto_basico_banco

-- DROP TABLE fin.punto_basico_banco;

CREATE TABLE fin.punto_basico_banco
(
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  banco character varying(15) NOT NULL, -- Codigo del banco que otorga el crédito
  linea_credito character varying(30) NOT NULL, -- linea del crédito unidirecto, tesoreria, credito rotativo, etc (tablagen CB_LINEA)
  puntos_basicos numeric NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  CONSTRAINT banco_pto_basico_fk FOREIGN KEY (banco, dstrct)
      REFERENCES bancos (codigo, dstrct) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fin.punto_basico_banco
  OWNER TO postgres;
COMMENT ON COLUMN fin.punto_basico_banco.banco IS 'Codigo del banco que otorga el crédito';
COMMENT ON COLUMN fin.punto_basico_banco.linea_credito IS 'linea del crédito unidirecto, tesoreria, credito rotativo, etc (tablagen CB_LINEA)';


