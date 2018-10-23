-- Table: con.factura

-- DROP TABLE con.factura;

CREATE TABLE con.factura
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  tipo_documento character varying(5) NOT NULL DEFAULT ''::character varying, -- tipo de documento como factura, prefactura, etc
  documento character varying(10) NOT NULL DEFAULT ''::character varying, -- numero de la factura
  nit character varying(15) DEFAULT ''::character varying, -- nit del cliente
  codcli character varying(10) NOT NULL DEFAULT ''::character varying, -- codigo cliente
  concepto character varying(8) NOT NULL DEFAULT ''::character varying,
  fecha_factura date DEFAULT '0099-01-01'::date, -- fecha que se genera la factura
  fecha_vencimiento date DEFAULT '0099-01-01'::date,
  fecha_ultimo_pago date DEFAULT '0099-01-01'::date,
  fecha_impresion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  descripcion text NOT NULL DEFAULT ''::text,
  observacion text NOT NULL DEFAULT ''::text,
  valor_factura moneda,
  valor_abono moneda,
  valor_saldo moneda,
  valor_facturame moneda, -- valor factura moneda extranjera
  valor_abonome moneda, -- valor abono moneda extranjera
  valor_saldome moneda, -- saldo moneda extranjera
  valor_tasa numeric(15,6) NOT NULL DEFAULT 0,
  moneda character varying(3) NOT NULL DEFAULT ''::character varying,
  cantidad_items numeric NOT NULL DEFAULT 0, -- numero de items que contiene la factura
  forma_pago character varying(15) DEFAULT ''::character varying,
  agencia_facturacion character varying(6) DEFAULT ''::character varying,
  agencia_cobro character varying(6) DEFAULT ''::character varying,
  zona character varying(10) DEFAULT ''::character varying,
  clasificacion1 character varying(6) DEFAULT ''::character varying, -- campos en blanco
  clasificacion2 character varying(6) DEFAULT ''::character varying, -- campos en blanco
  clasificacion3 character varying(6) DEFAULT ''::character varying, -- campos en blanco
  transaccion integer NOT NULL DEFAULT 0,
  transaccion_anulacion integer NOT NULL DEFAULT 0,
  fecha_contabilizacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  fecha_anulacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  fecha_contabilizacion_anulacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  fecha_probable_pago date DEFAULT '0099-01-01'::date, -- Campo donde se guarda la posible fecha de pago de la factura
  flujo character varying(1) NOT NULL DEFAULT 'S'::character varying, -- Flitro de Visualizacion para Flujo de Caja
  rif character varying(20) NOT NULL DEFAULT ''::character varying, -- Codigo de cliente venezolano
  cmc character varying(6) NOT NULL DEFAULT ''::character varying, -- Codigo de manejo contable
  usuario_anulo character varying(15) NOT NULL DEFAULT ''::character varying, -- Login del usuario que anulo el registro.
  formato character varying(6) NOT NULL DEFAULT ''::character varying, -- El formato de Impresión carbón o carga general
  agencia_impresion character varying(6) NOT NULL DEFAULT ''::character varying, -- Agencia de Impresion de la Factura
  periodo character varying(6) NOT NULL DEFAULT ''::character varying, -- Periodo contable
  valor_tasa_remesa numeric(15,6) NOT NULL DEFAULT 0,
  negasoc character varying(15) NOT NULL DEFAULT ''::character varying,
  num_doc_fen character varying(20) DEFAULT '0'::character varying,
  obs character varying(3) NOT NULL DEFAULT '0'::character varying,
  pagado_fenalco character varying(15), -- Numero del documento de la factura
  corficolombiana character varying(1) DEFAULT ''::character varying,
  tipo_ref1 character varying(50) DEFAULT ''::character varying,
  ref1 text DEFAULT ''::character varying,
  tipo_ref2 character varying(50) DEFAULT ''::character varying,
  ref2 text DEFAULT ''::text,
  dstrct_ultimo_ingreso character varying(4) NOT NULL DEFAULT ''::character varying,
  tipo_documento_ultimo_ingreso character varying(5) NOT NULL DEFAULT ''::character varying,
  num_ingreso_ultimo_ingreso character varying(11) NOT NULL DEFAULT ''::character varying,
  item_ultimo_ingreso integer NOT NULL DEFAULT 0,
  fec_envio_fiducia timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  nit_enviado_fiducia character varying,
  tipo_referencia_1 character varying(5) NOT NULL DEFAULT ''::character varying,
  referencia_1 character varying(30) NOT NULL DEFAULT ''::character varying,
  tipo_referencia_2 character varying(5) NOT NULL DEFAULT ''::character varying,
  referencia_2 character varying(30) NOT NULL DEFAULT ''::character varying,
  tipo_referencia_3 character varying(5) NOT NULL DEFAULT ''::character varying,
  referencia_3 character varying(30) NOT NULL DEFAULT ''::character varying,
  nc_traslado character varying(1) NOT NULL DEFAULT 'N'::character varying,
  fecha_nc_traslado timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  tipo_nc character varying(5) NOT NULL DEFAULT ''::character varying,
  numero_nc character varying(11) NOT NULL DEFAULT ''::character varying,
  factura_traslado character varying(10) NOT NULL DEFAULT ''::character varying,
  factoring_formula_aplicada character varying(1) NOT NULL DEFAULT 'N'::character varying,
  nit_endoso character varying(15) NOT NULL DEFAULT ''::character varying,
  devuelta character varying(1) NOT NULL DEFAULT ''::character varying,
  fc_eca character varying(15) DEFAULT ''::character varying, -- Indica la factura conformada para la comision eca generada en CxP
  fc_bonificacion character varying(15) DEFAULT ''::character varying, -- Indica la factura para la bonificacion generada en CxP
  indicador_bonificacion character varying(1) DEFAULT ''::character varying,
  fi_bonificacion character varying(15) DEFAULT ''::character varying,
  endoso_fenalco character varying(2) NOT NULL DEFAULT 'N'::character varying,
  endoso_fiducia character varying(1) NOT NULL DEFAULT 'N'::character varying,
  causacion_int_ms character varying(1) NOT NULL DEFAULT 'N'::character varying,
  fecha_causacion_int_ms timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  procesado character varying(1)
)
WITH (
  OIDS=TRUE
);
ALTER TABLE con.factura
  OWNER TO postgres;
GRANT ALL ON TABLE con.factura TO postgres;
GRANT SELECT ON TABLE con.factura TO msoto;
COMMENT ON COLUMN con.factura.tipo_documento IS 'tipo de documento como factura, prefactura, etc';
COMMENT ON COLUMN con.factura.documento IS 'numero de la factura';
COMMENT ON COLUMN con.factura.nit IS 'nit del cliente';
COMMENT ON COLUMN con.factura.codcli IS 'codigo cliente';
COMMENT ON COLUMN con.factura.fecha_factura IS 'fecha que se genera la factura';
COMMENT ON COLUMN con.factura.valor_facturame IS 'valor factura moneda extranjera';
COMMENT ON COLUMN con.factura.valor_abonome IS 'valor abono moneda extranjera';
COMMENT ON COLUMN con.factura.valor_saldome IS 'saldo moneda extranjera';
COMMENT ON COLUMN con.factura.cantidad_items IS 'numero de items que contiene la factura';
COMMENT ON COLUMN con.factura.clasificacion1 IS 'campos en blanco';
COMMENT ON COLUMN con.factura.clasificacion2 IS 'campos en blanco';
COMMENT ON COLUMN con.factura.clasificacion3 IS 'campos en blanco';
COMMENT ON COLUMN con.factura.fecha_probable_pago IS 'Campo donde se guarda la posible fecha de pago de la factura';
COMMENT ON COLUMN con.factura.flujo IS 'Flitro de Visualizacion para Flujo de Caja';
COMMENT ON COLUMN con.factura.rif IS 'Codigo de cliente venezolano';
COMMENT ON COLUMN con.factura.cmc IS 'Codigo de manejo contable';
COMMENT ON COLUMN con.factura.usuario_anulo IS 'Login del usuario que anulo el registro.';
COMMENT ON COLUMN con.factura.formato IS 'El formato de Impresión carbón o carga general';
COMMENT ON COLUMN con.factura.agencia_impresion IS 'Agencia de Impresion de la Factura';
COMMENT ON COLUMN con.factura.periodo IS 'Periodo contable';
COMMENT ON COLUMN con.factura.pagado_fenalco IS 'Numero del documento de la factura
';
COMMENT ON COLUMN con.factura.fc_eca IS 'Indica la factura conformada para la comision eca generada en CxP';
COMMENT ON COLUMN con.factura.fc_bonificacion IS 'Indica la factura para la bonificacion generada en CxP';


