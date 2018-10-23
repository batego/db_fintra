-- Table: con.cmc_doc

-- DROP TABLE con.cmc_doc;

CREATE TABLE con.cmc_doc
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  tipodoc character varying(5) NOT NULL DEFAULT ''::character varying, -- Tipo de documento contable
  cmc character varying(6) NOT NULL DEFAULT ''::character varying, -- Codigo de manejo contable
  cuenta character varying(25) NOT NULL DEFAULT ''::character varying, -- Cuenta contable
  dbcr character varying(1) NOT NULL DEFAULT ''::character varying, -- Indica si es debito (D) o credito ...
  tipo_cuenta character varying(1) NOT NULL DEFAULT ''::character varying, -- Indica si es cuenta (C) o ...
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  sigla_comprobante character varying(5) NOT NULL DEFAULT ''::character varying -- Sigla con la cual se crea el comprobante en el campo tipodoc
)
WITH (
  OIDS=TRUE
);
ALTER TABLE con.cmc_doc
  OWNER TO postgres;
GRANT ALL ON TABLE con.cmc_doc TO postgres;
GRANT SELECT ON TABLE con.cmc_doc TO msoto;
COMMENT ON TABLE con.cmc_doc
  IS 'Tabla para almacenar relacion de documentos 
y codigo de manejo contable.';
COMMENT ON COLUMN con.cmc_doc.tipodoc IS 'Tipo de documento contable';
COMMENT ON COLUMN con.cmc_doc.cmc IS 'Codigo de manejo contable';
COMMENT ON COLUMN con.cmc_doc.cuenta IS 'Cuenta contable';
COMMENT ON COLUMN con.cmc_doc.dbcr IS 'Indica si es debito (D) o credito 
(C)';
COMMENT ON COLUMN con.cmc_doc.tipo_cuenta IS 'Indica si es cuenta (C) o 
elemento del gasto (E)';
COMMENT ON COLUMN con.cmc_doc.sigla_comprobante IS 'Sigla con la cual se crea el comprobante en el campo tipodoc';


