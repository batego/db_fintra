-- Table: fin.credito_bancario_detalle

-- DROP TABLE fin.credito_bancario_detalle;

CREATE TABLE fin.credito_bancario_detalle
(
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  nit_banco character varying(15) NOT NULL, -- Nit del banco que otorga el crédito
  documento character varying(30) NOT NULL, -- Numero de documento que asigna el banco
  id smallint NOT NULL, -- Consecutivo para los detalles del crédito
  fecha_inicial date NOT NULL, -- Fecha inicial del periodo para el cual se calculan los intereses
  fecha_final date NOT NULL, -- Fecha final del periodo para el cual se calculan los intereses
  dtf numeric NOT NULL, -- DTF utilizado para el calculo de los intereses
  saldo_inicial double precision NOT NULL, -- Saldo inicial del periodo
  capital_inicial double precision NOT NULL, -- Capital al inicio del periodo
  intereses double precision, -- Intereses calculados para este periodo
  ajuste_intereses double precision, -- Ajuste a los intereses calculados para que coincidan con los del banco
  pago_capital double precision, -- Cantidad que se pago a capital
  pago_intereses double precision, -- Cantidad que se pago de intereses
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  interes_acumulado double precision, -- Intereses acumulados hasta la fecha
  doc_intereses character varying(30), -- documento contable generado para la causacion de intereses
  doc_pago character varying(30), -- documento contable generado para el pago
  procesado_apo character varying(1) NOT NULL DEFAULT 'N'::character varying,
  CONSTRAINT credito_bancario_credito_bancario_detalle_fk FOREIGN KEY (dstrct, nit_banco, documento)
      REFERENCES fin.credito_bancario (dstrct, nit_banco, documento) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fin.credito_bancario_detalle
  OWNER TO postgres;
COMMENT ON TABLE fin.credito_bancario_detalle
  IS 'Guarda todos los movimientos realizados a un credito bancario';
COMMENT ON COLUMN fin.credito_bancario_detalle.nit_banco IS 'Nit del banco que otorga el crédito';
COMMENT ON COLUMN fin.credito_bancario_detalle.documento IS 'Numero de documento que asigna el banco';
COMMENT ON COLUMN fin.credito_bancario_detalle.id IS 'Consecutivo para los detalles del crédito';
COMMENT ON COLUMN fin.credito_bancario_detalle.fecha_inicial IS 'Fecha inicial del periodo para el cual se calculan los intereses';
COMMENT ON COLUMN fin.credito_bancario_detalle.fecha_final IS 'Fecha final del periodo para el cual se calculan los intereses';
COMMENT ON COLUMN fin.credito_bancario_detalle.dtf IS 'DTF utilizado para el calculo de los intereses';
COMMENT ON COLUMN fin.credito_bancario_detalle.saldo_inicial IS 'Saldo inicial del periodo';
COMMENT ON COLUMN fin.credito_bancario_detalle.capital_inicial IS 'Capital al inicio del periodo';
COMMENT ON COLUMN fin.credito_bancario_detalle.intereses IS 'Intereses calculados para este periodo';
COMMENT ON COLUMN fin.credito_bancario_detalle.ajuste_intereses IS 'Ajuste a los intereses calculados para que coincidan con los del banco';
COMMENT ON COLUMN fin.credito_bancario_detalle.pago_capital IS 'Cantidad que se pago a capital';
COMMENT ON COLUMN fin.credito_bancario_detalle.pago_intereses IS 'Cantidad que se pago de intereses';
COMMENT ON COLUMN fin.credito_bancario_detalle.interes_acumulado IS 'Intereses acumulados hasta la fecha';
COMMENT ON COLUMN fin.credito_bancario_detalle.doc_intereses IS 'documento contable generado para la causacion de intereses';
COMMENT ON COLUMN fin.credito_bancario_detalle.doc_pago IS 'documento contable generado para el pago';


