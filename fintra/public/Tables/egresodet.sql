-- Table: egresodet

-- DROP TABLE egresodet;

CREATE TABLE egresodet
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  branch_code character varying(15) NOT NULL DEFAULT ''::character varying,
  bank_account_no character varying(30) NOT NULL DEFAULT ''::character varying,
  document_no character varying(17) NOT NULL DEFAULT ''::character varying,
  item_no character varying(15) NOT NULL DEFAULT ''::character varying,
  concept_code character varying(60) NOT NULL DEFAULT ''::character varying,
  vlr numeric(15,2) NOT NULL DEFAULT 0.0,
  vlr_for numeric(15,2) NOT NULL DEFAULT 0.0,
  currency character varying(3) NOT NULL DEFAULT ''::character varying,
  oc character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  description text DEFAULT ''::text, -- DescripciÃ³n del item
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  tasa numeric(18,10) NOT NULL DEFAULT 0, -- Tasa de conversion
  transaccion integer NOT NULL DEFAULT 0, -- Indica el numero de la transaccion relacionada a la contabilidad
  tipo_documento character varying(15) NOT NULL DEFAULT ''::character varying, -- Codigo del tipo de documento
  documento character varying(30) NOT NULL DEFAULT ''::character varying, -- Codigo del documento
  tipo_pago character varying(1) NOT NULL DEFAULT ''::character varying, -- Tipo de pago de la factura A si es abono, C si es cancelacion
  cuenta character varying(25) NOT NULL DEFAULT ''::character varying,
  auxiliar character varying(25) NOT NULL DEFAULT ''::character varying,
  procesado character varying(1) DEFAULT 'N'::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE egresodet
  OWNER TO postgres;
GRANT ALL ON TABLE egresodet TO postgres;
GRANT SELECT ON TABLE egresodet TO msoto;
COMMENT ON COLUMN egresodet.description IS 'DescripciÃ³n del item';
COMMENT ON COLUMN egresodet.tasa IS 'Tasa de conversion';
COMMENT ON COLUMN egresodet.transaccion IS 'Indica el numero de la transaccion relacionada a la contabilidad';
COMMENT ON COLUMN egresodet.tipo_documento IS 'Codigo del tipo de documento';
COMMENT ON COLUMN egresodet.documento IS 'Codigo del documento';
COMMENT ON COLUMN egresodet.tipo_pago IS 'Tipo de pago de la factura A si es abono, C si es cancelacion';


