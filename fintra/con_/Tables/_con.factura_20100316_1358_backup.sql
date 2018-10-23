-- Table: con.factura_20100316_1358_backup

-- DROP TABLE con.factura_20100316_1358_backup;

CREATE TABLE con.factura_20100316_1358_backup
(
  reg_status character varying(1),
  dstrct character varying(4),
  tipo_documento character varying(5),
  documento character varying(10),
  nit character varying(15),
  codcli character varying(10),
  concepto character varying(6),
  fecha_factura date,
  fecha_vencimiento date,
  fecha_ultimo_pago date,
  fecha_impresion timestamp without time zone,
  descripcion text,
  observacion text,
  valor_factura moneda,
  valor_abono moneda,
  valor_saldo moneda,
  valor_facturame moneda,
  valor_abonome moneda,
  valor_saldome moneda,
  valor_tasa numeric(15,6),
  moneda character varying(3),
  cantidad_items numeric,
  forma_pago character varying(15),
  agencia_facturacion character varying(6),
  agencia_cobro character varying(6),
  zona character varying(10),
  clasificacion1 character varying(6),
  clasificacion2 character varying(6),
  clasificacion3 character varying(6),
  transaccion integer,
  transaccion_anulacion integer,
  fecha_contabilizacion timestamp without time zone,
  fecha_anulacion timestamp without time zone,
  fecha_contabilizacion_anulacion timestamp without time zone,
  base character varying(3),
  last_update timestamp without time zone,
  user_update character varying(10),
  creation_date timestamp without time zone,
  creation_user character varying(10),
  fecha_probable_pago date,
  flujo character varying(1),
  rif character varying(20),
  cmc character varying(6),
  usuario_anulo character varying(15),
  formato character varying(6),
  agencia_impresion character varying(6),
  periodo character varying(6),
  valor_tasa_remesa numeric(15,6),
  negasoc character varying(15),
  num_doc_fen character varying(20),
  obs character varying(3),
  pagado_fenalco character varying(15),
  corficolombiana character varying(1),
  tipo_ref1 character varying(50),
  ref1 text,
  tipo_ref2 character varying(50),
  ref2 text,
  dstrct_ultimo_ingreso character varying(4),
  tipo_documento_ultimo_ingreso character varying(5),
  num_ingreso_ultimo_ingreso character varying(11),
  item_ultimo_ingreso integer,
  fec_envio_fiducia timestamp without time zone,
  nit_enviado_fiducia character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.factura_20100316_1358_backup
  OWNER TO postgres;
GRANT ALL ON TABLE con.factura_20100316_1358_backup TO postgres;
GRANT SELECT ON TABLE con.factura_20100316_1358_backup TO msoto;

