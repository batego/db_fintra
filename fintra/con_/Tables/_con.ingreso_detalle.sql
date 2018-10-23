-- Table: con.ingreso_detalle

-- DROP TABLE con.ingreso_detalle;

CREATE TABLE con.ingreso_detalle
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  tipo_documento character varying(5) NOT NULL DEFAULT ''::character varying, -- Tipo de documento del ingreso
  num_ingreso character varying(11) NOT NULL DEFAULT ''::character varying, -- Numero del ingreso del cliente
  item bigint NOT NULL DEFAULT 0, -- Consecutivo del ingreso del cliente
  nitcli character varying(15) DEFAULT ''::character varying, -- NIT del cliente
  valor_ingreso moneda NOT NULL DEFAULT 0, -- Valor del ingreso del cliente en moneda local
  valor_ingreso_me moneda NOT NULL DEFAULT 0, -- Valor del ingreso del cliente en moneda extranjera
  factura character varying(10) NOT NULL DEFAULT ''::character varying, -- Numero de la factura del cliente
  fecha_factura date NOT NULL DEFAULT '0099-01-01'::date,
  codigo_retefuente character varying(6) NOT NULL DEFAULT ''::character varying, -- Codigo del porcentaje de la retefuente
  valor_retefuente moneda NOT NULL DEFAULT 0, -- Valor de la retefuente del cliente en moneda local
  valor_retefuente_me moneda NOT NULL DEFAULT 0, -- Valor de la retefuente del cliente en moneda extranjera
  tipo_doc character varying(5) NOT NULL DEFAULT ''::character varying, -- Tipo de documento del detalle del ingreso
  documento text NOT NULL DEFAULT ''::character varying, -- Documento del detalle de ingreso
  codigo_reteica character varying(6) NOT NULL DEFAULT ''::character varying, -- Codigo del porcentaje de la reteica
  valor_reteica moneda NOT NULL DEFAULT 0, -- Valor de la reteica del cliente en moneda local
  valor_reteica_me moneda NOT NULL DEFAULT 0, -- Valor de la reteica del cliente en moneda extranjera
  valor_diferencia_tasa moneda NOT NULL DEFAULT 0, -- Valor de la diferencia de la tasa
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  cuenta character varying(25) NOT NULL DEFAULT ''::character varying, -- Cuenta contable
  auxiliar character varying(25) NOT NULL DEFAULT ''::character varying, -- Codigo contable auxiliar o Sublegers
  fecha_contabilizacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- fecha de contabilizacion
  fecha_anulacion_contabilizacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- fecha anulacion contabilizacion
  periodo character varying(6) NOT NULL DEFAULT ''::character varying, -- periodo de contabilizacion del ingreso
  fecha_anulacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- fecha anulacion
  periodo_anulacion character varying(6) NOT NULL DEFAULT ''::character varying, -- periodo de anulacion de contabilizacion del ingreso
  transaccion integer NOT NULL DEFAULT 0, -- Anulacion de la identificacion unica del comprobante en contabilidad
  transaccion_anulacion integer NOT NULL DEFAULT 0,
  descripcion text NOT NULL DEFAULT ''::text,
  valor_tasa numeric(15,10) NOT NULL DEFAULT 0, -- Valor de la tasa del ingreso
  saldo_factura moneda NOT NULL DEFAULT 0, -- Valor del saldo de la factura al momneto del ingreso
  procesado character varying NOT NULL DEFAULT 'NO'::character varying,
  id serial NOT NULL,
  ref1 text,
  tipo_referencia_1 character varying(5) NOT NULL DEFAULT ''::character varying,
  referencia_1 character varying(30) NOT NULL DEFAULT ''::character varying,
  tipo_referencia_2 character varying(5) NOT NULL DEFAULT ''::character varying,
  referencia_2 character varying(30) NOT NULL DEFAULT ''::character varying,
  tipo_referencia_3 character varying(5) NOT NULL DEFAULT ''::character varying,
  referencia_3 character varying(30) NOT NULL DEFAULT ''::character varying,
  procesado_ica character varying(1) DEFAULT 'N'::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.ingreso_detalle
  OWNER TO postgres;
GRANT ALL ON TABLE con.ingreso_detalle TO postgres;
GRANT SELECT ON TABLE con.ingreso_detalle TO msoto;
COMMENT ON TABLE con.ingreso_detalle
  IS 'Tabla de Detalles de ingresos de clientes';
COMMENT ON COLUMN con.ingreso_detalle.tipo_documento IS 'Tipo de documento del ingreso';
COMMENT ON COLUMN con.ingreso_detalle.num_ingreso IS 'Numero del ingreso del cliente';
COMMENT ON COLUMN con.ingreso_detalle.item IS 'Consecutivo del ingreso del cliente';
COMMENT ON COLUMN con.ingreso_detalle.nitcli IS 'NIT del cliente';
COMMENT ON COLUMN con.ingreso_detalle.valor_ingreso IS 'Valor del ingreso del cliente en moneda local';
COMMENT ON COLUMN con.ingreso_detalle.valor_ingreso_me IS 'Valor del ingreso del cliente en moneda extranjera';
COMMENT ON COLUMN con.ingreso_detalle.factura IS 'Numero de la factura del cliente';
COMMENT ON COLUMN con.ingreso_detalle.codigo_retefuente IS 'Codigo del porcentaje de la retefuente';
COMMENT ON COLUMN con.ingreso_detalle.valor_retefuente IS 'Valor de la retefuente del cliente en moneda local';
COMMENT ON COLUMN con.ingreso_detalle.valor_retefuente_me IS 'Valor de la retefuente del cliente en moneda extranjera';
COMMENT ON COLUMN con.ingreso_detalle.tipo_doc IS 'Tipo de documento del detalle del ingreso';
COMMENT ON COLUMN con.ingreso_detalle.documento IS 'Documento del detalle de ingreso';
COMMENT ON COLUMN con.ingreso_detalle.codigo_reteica IS 'Codigo del porcentaje de la reteica';
COMMENT ON COLUMN con.ingreso_detalle.valor_reteica IS 'Valor de la reteica del cliente en moneda local';
COMMENT ON COLUMN con.ingreso_detalle.valor_reteica_me IS 'Valor de la reteica del cliente en moneda extranjera';
COMMENT ON COLUMN con.ingreso_detalle.valor_diferencia_tasa IS 'Valor de la diferencia de la tasa';
COMMENT ON COLUMN con.ingreso_detalle.cuenta IS 'Cuenta contable';
COMMENT ON COLUMN con.ingreso_detalle.auxiliar IS 'Codigo contable auxiliar o Sublegers';
COMMENT ON COLUMN con.ingreso_detalle.fecha_contabilizacion IS 'fecha de contabilizacion';
COMMENT ON COLUMN con.ingreso_detalle.fecha_anulacion_contabilizacion IS 'fecha anulacion contabilizacion';
COMMENT ON COLUMN con.ingreso_detalle.periodo IS 'periodo de contabilizacion del ingreso';
COMMENT ON COLUMN con.ingreso_detalle.fecha_anulacion IS 'fecha anulacion';
COMMENT ON COLUMN con.ingreso_detalle.periodo_anulacion IS 'periodo de anulacion de contabilizacion del ingreso';
COMMENT ON COLUMN con.ingreso_detalle.transaccion IS 'Anulacion de la identificacion unica del comprobante en contabilidad';
COMMENT ON COLUMN con.ingreso_detalle.valor_tasa IS 'Valor de la tasa del ingreso';
COMMENT ON COLUMN con.ingreso_detalle.saldo_factura IS 'Valor del saldo de la factura al momneto del ingreso';


