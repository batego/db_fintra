-- Table: recaudo.pagos_masivos_lineas

-- DROP TABLE recaudo.pagos_masivos_lineas;

CREATE TABLE recaudo.pagos_masivos_lineas
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  negocio character varying(15) NOT NULL DEFAULT ''::character varying, -- Codigo del Negocio
  identificacion character varying(15) NOT NULL DEFAULT ''::character varying, -- Identificacion del Cliente
  unidad_negocio character varying(6) NOT NULL DEFAULT ''::character varying, -- Unidad de Negocio
  banco character varying(15) NOT NULL DEFAULT ''::character varying, -- Banco
  sucursal character varying(30) NOT NULL DEFAULT ''::character varying, -- Sucursal
  valor_aplicar_neto moneda, -- Valor Neto
  mora moneda, -- Gastos de Mora
  gac moneda, -- Gastos de Cobranza
  tipo_pago character varying(1) NOT NULL DEFAULT ''::character varying, -- Tipo de Pago
  cta_mora character varying(25) NOT NULL DEFAULT ''::character varying, -- Cuenta de Mora
  cta_gac character varying(25) NOT NULL DEFAULT ''::character varying, -- Cuenta Gastos de Cobranza
  id_rop integer,
  reg_procesado character varying(1) NOT NULL DEFAULT 'N'::character varying, -- Campo en el cual se marca si ya ha sido procesado el pago N->NO y S->SI
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE recaudo.pagos_masivos_lineas
  OWNER TO postgres;
GRANT ALL ON TABLE recaudo.pagos_masivos_lineas TO postgres;
COMMENT ON TABLE recaudo.pagos_masivos_lineas
  IS 'Tabla para almacenar temporalmente los pagos a las diferentes lineas de credito';
COMMENT ON COLUMN recaudo.pagos_masivos_lineas.negocio IS 'Codigo del Negocio';
COMMENT ON COLUMN recaudo.pagos_masivos_lineas.identificacion IS 'Identificacion del Cliente';
COMMENT ON COLUMN recaudo.pagos_masivos_lineas.unidad_negocio IS 'Unidad de Negocio';
COMMENT ON COLUMN recaudo.pagos_masivos_lineas.banco IS 'Banco';
COMMENT ON COLUMN recaudo.pagos_masivos_lineas.sucursal IS 'Sucursal';
COMMENT ON COLUMN recaudo.pagos_masivos_lineas.valor_aplicar_neto IS 'Valor Neto';
COMMENT ON COLUMN recaudo.pagos_masivos_lineas.mora IS 'Gastos de Mora';
COMMENT ON COLUMN recaudo.pagos_masivos_lineas.gac IS 'Gastos de Cobranza';
COMMENT ON COLUMN recaudo.pagos_masivos_lineas.tipo_pago IS 'Tipo de Pago';
COMMENT ON COLUMN recaudo.pagos_masivos_lineas.cta_mora IS 'Cuenta de Mora';
COMMENT ON COLUMN recaudo.pagos_masivos_lineas.cta_gac IS 'Cuenta Gastos de Cobranza';
COMMENT ON COLUMN recaudo.pagos_masivos_lineas.reg_procesado IS 'Campo en el cual se marca si ya ha sido procesado el pago N->NO y S->SI';


