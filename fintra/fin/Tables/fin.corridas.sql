-- Table: fin.corridas

-- DROP TABLE fin.corridas;

CREATE TABLE fin.corridas
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying, -- El distrito
  corrida numeric(10,0) NOT NULL DEFAULT 0, -- NÃƒÆ’Ã‚Âºmero de corrida
  tipo_documento character varying(15) NOT NULL DEFAULT ''::character varying, -- Tipo de documento de la factura
  documento character varying(30) NOT NULL DEFAULT ''::character varying, -- Numero de factura
  beneficiario character varying(15) NOT NULL DEFAULT ''::character varying, -- Codigo del beneficiario
  nombre character varying(100) NOT NULL DEFAULT ''::character varying, -- Nombre del beneficiario
  valor moneda, -- Valor de la factura
  valor_me moneda, -- Valor de la factura moneda extranjera
  planilla character varying(10) NOT NULL DEFAULT ''::character varying, -- Numero de la planilla
  placa character varying(12) NOT NULL DEFAULT ''::character varying, -- Placa de la planilla
  banco character varying(30) NOT NULL DEFAULT ''::character varying, -- Banco
  sucursal character varying(30) NOT NULL DEFAULT ''::character varying, -- Sucursal del banco
  agencia_banco character varying(30) NOT NULL DEFAULT ''::character varying, -- Agencia del banco
  moneda character varying(3) NOT NULL DEFAULT ''::character varying, -- Moneda del banco
  cheque character varying(15) NOT NULL DEFAULT ''::character varying, -- Numero del cheque para la factura
  impresion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Fecha de impresion
  usuario_impresion character varying(15) NOT NULL DEFAULT ''::character varying, -- Usuario que imprime
  pago timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Fecha autorizacion del pago
  usuario_pago character varying(15) NOT NULL DEFAULT ''::character varying, -- Usuario que aprueba el pago
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(15) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  tipo_pago character varying(2) NOT NULL DEFAULT 'B'::character varying, -- Determina el tipo de pago que se le realiza
  banco_transfer character varying(15) NOT NULL DEFAULT ''::character varying, -- El banco donde se realizara la transferencia
  suc_transfer character varying(15) NOT NULL DEFAULT ''::character varying, -- Sucursal de la transferencia
  tipo_cuenta character varying(3) NOT NULL DEFAULT ''::character varying, -- Tipo de la cuenta
  no_cuenta character varying(20) NOT NULL DEFAULT ''::character varying, -- Numero de la cuenta
  cedula_cuenta character varying(15) NOT NULL DEFAULT ''::character varying, -- Cedula de la cuenta
  nombre_cuenta character varying(100) NOT NULL DEFAULT ''::character varying, -- Nombre de la cuenta
  banco_pago_tr character varying(30) NOT NULL DEFAULT ''::character varying, -- Banco por el cual se paga la transferencia
  sucursal_pago_tr character varying(30) NOT NULL DEFAULT ''::character varying, -- Sucursal banco pago de la transferencia
  transferencia character varying(30) NOT NULL DEFAULT ''::character varying -- NÃƒÂºmero de la transferencia
)
WITH (
  OIDS=TRUE
);
ALTER TABLE fin.corridas
  OWNER TO postgres;
COMMENT ON TABLE fin.corridas
  IS 'Guarda las corridas generadas con sus facturas';
COMMENT ON COLUMN fin.corridas.dstrct IS 'El distrito';
COMMENT ON COLUMN fin.corridas.corrida IS 'NÃƒÆ’Ã‚Âºmero de corrida';
COMMENT ON COLUMN fin.corridas.tipo_documento IS 'Tipo de documento de la factura';
COMMENT ON COLUMN fin.corridas.documento IS 'Numero de factura';
COMMENT ON COLUMN fin.corridas.beneficiario IS 'Codigo del beneficiario';
COMMENT ON COLUMN fin.corridas.nombre IS 'Nombre del beneficiario';
COMMENT ON COLUMN fin.corridas.valor IS 'Valor de la factura';
COMMENT ON COLUMN fin.corridas.valor_me IS 'Valor de la factura moneda extranjera';
COMMENT ON COLUMN fin.corridas.planilla IS 'Numero de la planilla';
COMMENT ON COLUMN fin.corridas.placa IS 'Placa de la planilla';
COMMENT ON COLUMN fin.corridas.banco IS 'Banco ';
COMMENT ON COLUMN fin.corridas.sucursal IS 'Sucursal del banco';
COMMENT ON COLUMN fin.corridas.agencia_banco IS 'Agencia del banco';
COMMENT ON COLUMN fin.corridas.moneda IS 'Moneda del banco';
COMMENT ON COLUMN fin.corridas.cheque IS 'Numero del cheque para la factura';
COMMENT ON COLUMN fin.corridas.impresion IS 'Fecha de impresion';
COMMENT ON COLUMN fin.corridas.usuario_impresion IS 'Usuario que imprime';
COMMENT ON COLUMN fin.corridas.pago IS 'Fecha autorizacion del pago';
COMMENT ON COLUMN fin.corridas.usuario_pago IS 'Usuario que aprueba el pago';
COMMENT ON COLUMN fin.corridas.tipo_pago IS 'Determina el tipo de pago que se le realiza';
COMMENT ON COLUMN fin.corridas.banco_transfer IS 'El banco donde se realizara la transferencia';
COMMENT ON COLUMN fin.corridas.suc_transfer IS 'Sucursal de la transferencia';
COMMENT ON COLUMN fin.corridas.tipo_cuenta IS 'Tipo de la cuenta';
COMMENT ON COLUMN fin.corridas.no_cuenta IS 'Numero de la cuenta';
COMMENT ON COLUMN fin.corridas.cedula_cuenta IS 'Cedula de la cuenta';
COMMENT ON COLUMN fin.corridas.nombre_cuenta IS 'Nombre de la cuenta';
COMMENT ON COLUMN fin.corridas.banco_pago_tr IS 'Banco por el cual se paga la transferencia';
COMMENT ON COLUMN fin.corridas.sucursal_pago_tr IS 'Sucursal banco pago de la transferencia';
COMMENT ON COLUMN fin.corridas.transferencia IS 'NÃƒÂºmero de la transferencia';


