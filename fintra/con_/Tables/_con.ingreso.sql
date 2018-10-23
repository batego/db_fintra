-- Table: con.ingreso

-- DROP TABLE con.ingreso;

CREATE TABLE con.ingreso
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(15) NOT NULL DEFAULT ''::character varying,
  tipo_documento character varying(5) NOT NULL DEFAULT ''::character varying, -- Tipo de documento del Ingreso
  num_ingreso character varying(11) NOT NULL DEFAULT ''::character varying, -- numero de ingreso
  codcli character varying(10) NOT NULL DEFAULT ''::character varying, -- codigo del cliente
  nitcli character varying(15) DEFAULT ''::character varying, -- nit del cliente
  concepto character varying(30) NOT NULL DEFAULT ''::character varying, -- concepto de ingreso
  tipo_ingreso character varying(2) NOT NULL DEFAULT ''::character varying, -- tipo de ingreso 'C' cliente, 'M' miselaneo
  fecha_consignacion date NOT NULL DEFAULT '0099-01-01'::date, -- fecha en que se realizo la consignacion
  fecha_ingreso date NOT NULL DEFAULT '0099-01-01'::date, -- fecha en que se realiza el ingreso
  branch_code character varying(15) NOT NULL DEFAULT ''::character varying, -- banco de consignacion
  bank_account_no character varying(30) NOT NULL DEFAULT ''::character varying, -- sucursal del banco de consignacion
  codmoneda character varying(3) NOT NULL DEFAULT ''::character varying, -- moneda de la consignacion
  agencia_ingreso character varying(6) NOT NULL DEFAULT ''::character varying, -- agencia realiza el ingreso
  descripcion_ingreso text NOT NULL DEFAULT ''::character varying, -- descripcion de ingreso
  periodo character varying(6) NOT NULL DEFAULT ''::character varying,
  vlr_ingreso moneda, -- valor de ingreso
  vlr_ingreso_me moneda, -- valor de imgreso moneda extranjera
  vlr_tasa numeric(15,6) NOT NULL DEFAULT 0.0, -- valor de conversion
  fecha_tasa date NOT NULL DEFAULT '0099-01-01'::date, -- fecha de la tasa
  cant_item numeric(4,0) DEFAULT 0, -- numero de items que existen en la tabla ingreso detalle
  transaccion integer NOT NULL DEFAULT 0, -- Identificacion unica del comprobante en contabilidad
  transaccion_anulacion integer NOT NULL DEFAULT 0,
  fecha_impresion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- fecha de impresion
  fecha_contabilizacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- fecha de contabilizacion
  fecha_anulacion_contabilizacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- fecha anulacion contabilizacion
  fecha_anulacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- fecha anulacion
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  nro_consignacion character varying(25) NOT NULL DEFAULT ''::character varying,
  periodo_anulacion character varying(6) NOT NULL DEFAULT ''::character varying,
  cuenta character varying(25) NOT NULL DEFAULT ''::character varying, -- Cuenta contable para las Nota Creditos
  auxiliar character varying(25) NOT NULL DEFAULT ''::character varying, -- Codigo tipo de subledger
  abc character varying(30) NOT NULL DEFAULT ''::character varying, -- Codigo ABC de las notas creditos del ingreso
  tasa_dol_bol numeric(15,6) NOT NULL DEFAULT 0, -- La tasa de conversiÃ³n de Dolares a Bolivares
  saldo_ingreso moneda NOT NULL DEFAULT 0, -- El valor del saldo del ingreso
  cmc character varying(5) DEFAULT '00'::character varying,
  corficolombiana character varying(1) DEFAULT ''::character varying,
  fec_envio_fiducia timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  tipo_referencia_1 character varying(5) NOT NULL DEFAULT ''::character varying,
  referencia_1 character varying(30) NOT NULL DEFAULT ''::character varying,
  tipo_referencia_2 character varying(5) NOT NULL DEFAULT ''::character varying,
  referencia_2 character varying(30) NOT NULL DEFAULT ''::character varying,
  tipo_referencia_3 character varying(5) NOT NULL DEFAULT ''::character varying,
  referencia_3 character varying(30) NOT NULL DEFAULT ''::character varying,
  nc_ecce character varying(30) NOT NULL DEFAULT ''::character varying, -- Indica la NC que se elaboro para abonar a las facturas de comision ECA EC o CE
  nro_extracto integer NOT NULL DEFAULT 0
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.ingreso
  OWNER TO postgres;
GRANT ALL ON TABLE con.ingreso TO postgres;
GRANT SELECT ON TABLE con.ingreso TO msoto;
COMMENT ON TABLE con.ingreso
  IS 'Tabla de ingreso de pagos por clientes';
COMMENT ON COLUMN con.ingreso.tipo_documento IS 'Tipo de documento del Ingreso';
COMMENT ON COLUMN con.ingreso.num_ingreso IS 'numero de ingreso';
COMMENT ON COLUMN con.ingreso.codcli IS 'codigo del cliente';
COMMENT ON COLUMN con.ingreso.nitcli IS 'nit del cliente';
COMMENT ON COLUMN con.ingreso.concepto IS 'concepto de ingreso';
COMMENT ON COLUMN con.ingreso.tipo_ingreso IS 'tipo de ingreso ''C'' cliente, ''M'' miselaneo';
COMMENT ON COLUMN con.ingreso.fecha_consignacion IS 'fecha en que se realizo la consignacion';
COMMENT ON COLUMN con.ingreso.fecha_ingreso IS 'fecha en que se realiza el ingreso';
COMMENT ON COLUMN con.ingreso.branch_code IS 'banco de consignacion';
COMMENT ON COLUMN con.ingreso.bank_account_no IS 'sucursal del banco de consignacion';
COMMENT ON COLUMN con.ingreso.codmoneda IS 'moneda de la consignacion';
COMMENT ON COLUMN con.ingreso.agencia_ingreso IS 'agencia realiza el ingreso';
COMMENT ON COLUMN con.ingreso.descripcion_ingreso IS 'descripcion de ingreso';
COMMENT ON COLUMN con.ingreso.vlr_ingreso IS 'valor de ingreso';
COMMENT ON COLUMN con.ingreso.vlr_ingreso_me IS 'valor de imgreso moneda extranjera';
COMMENT ON COLUMN con.ingreso.vlr_tasa IS 'valor de conversion';
COMMENT ON COLUMN con.ingreso.fecha_tasa IS 'fecha de la tasa';
COMMENT ON COLUMN con.ingreso.cant_item IS 'numero de items que existen en la tabla ingreso detalle';
COMMENT ON COLUMN con.ingreso.transaccion IS 'Identificacion unica del comprobante en contabilidad';
COMMENT ON COLUMN con.ingreso.fecha_impresion IS 'fecha de impresion';
COMMENT ON COLUMN con.ingreso.fecha_contabilizacion IS 'fecha de contabilizacion';
COMMENT ON COLUMN con.ingreso.fecha_anulacion_contabilizacion IS 'fecha anulacion contabilizacion';
COMMENT ON COLUMN con.ingreso.fecha_anulacion IS 'fecha anulacion';
COMMENT ON COLUMN con.ingreso.cuenta IS 'Cuenta contable para las Nota Creditos';
COMMENT ON COLUMN con.ingreso.auxiliar IS 'Codigo tipo de subledger';
COMMENT ON COLUMN con.ingreso.abc IS 'Codigo ABC de las notas creditos del ingreso';
COMMENT ON COLUMN con.ingreso.tasa_dol_bol IS 'La tasa de conversiÃ³n de Dolares a Bolivares';
ALTER TABLE con.ingreso ALTER COLUMN tasa_dol_bol SET STORAGE EXTENDED;
COMMENT ON COLUMN con.ingreso.saldo_ingreso IS 'El valor del saldo del ingreso';
ALTER TABLE con.ingreso ALTER COLUMN saldo_ingreso SET STORAGE EXTENDED;
COMMENT ON COLUMN con.ingreso.nc_ecce IS 'Indica la NC que se elaboro para abonar a las facturas de comision ECA EC o CE';


