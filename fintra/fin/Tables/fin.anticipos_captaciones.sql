-- Table: fin.anticipos_captaciones

-- DROP TABLE fin.anticipos_captaciones;

CREATE TABLE fin.anticipos_captaciones
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  id serial NOT NULL, -- Identificador del registro
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  agency_id character varying(10) NOT NULL DEFAULT ''::character varying, -- Agencia  que realiza el anticipo
  pla_owner character varying(15) NOT NULL DEFAULT ''::character varying, -- Nit del propietario de la planilla
  planilla character varying(10) NOT NULL DEFAULT ''::character varying, -- Numero de la planilla
  supplier character varying(10) NOT NULL DEFAULT ''::character varying, -- Placa
  proveedor_anticipo character varying(15) NOT NULL DEFAULT ''::character varying, -- Nit tercero de anticipos en planilla
  concept_code character varying(12) NOT NULL DEFAULT ''::character varying, -- Codigo del concepto del descuento
  vlr numeric(15,2) NOT NULL DEFAULT 0.0, -- Valor moneda local
  vlr_for numeric(15,2) NOT NULL DEFAULT 0.0, -- Valor en moneda foranea
  currency character varying(3) NOT NULL DEFAULT ''::character varying, -- Moneda
  fecha_anticipo timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Fecha en que se grabÃ³ el anticipo
  aprobado character varying(1) NOT NULL DEFAULT 'N'::character varying, -- Indica si el anticipo es aprobado para transferir dinero
  fecha_autorizacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Fecha en que se realizÃ³ la autorizaciÃ³n para pago anticipo
  user_autorizacion character varying(10) NOT NULL DEFAULT ''::character varying, -- Usuario que realizÃ³ la autorizaciÃ³n
  transferido character varying(1) NOT NULL DEFAULT 'N'::character varying, -- Indica si se realizÃ³ la transferencia del dinero
  fecha_transferencia timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Fecha en que se realizÃ³ la transferencia
  banco_transferencia character varying(30) NOT NULL DEFAULT ''::character varying, -- Banco de la cuenta credito
  cuenta_transferencia character varying(20) NOT NULL DEFAULT ''::character varying, -- NÃºmero de la cuenta credito
  tcta_transferencia character varying(4) NOT NULL DEFAULT ''::character varying, -- Tipo de cuenta credito
  user_transferencia character varying(10) NOT NULL DEFAULT ''::character varying, -- Usuario que realizÃ³ la transferencia
  banco character varying(30) NOT NULL DEFAULT ''::character varying, -- Banco a transferir dinero
  sucursal character varying(30) NOT NULL DEFAULT ''::character varying, -- Sucursal banco a transferir dinero
  nombre_cuenta character varying(50) NOT NULL DEFAULT ''::character varying, -- Nombre cuenta a transferir dinero
  cuenta character varying(20) NOT NULL DEFAULT ''::character varying, -- Cuenta a transferir dinero
  tipo_cuenta character varying(2) NOT NULL DEFAULT ''::character varying, -- Tipo de cuenta  a transferir dinero
  nit_cuenta character varying(20) NOT NULL DEFAULT ''::character varying, -- Nit de la cuenta a transferir dinero
  fecha_migracion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Fecha en que se generÃ³ el archivo de migracion a mims
  user_migracion character varying(10) NOT NULL DEFAULT ''::character varying,
  factura_mims character varying(15) NOT NULL DEFAULT ''::character varying, -- Factura con que se sube a mims
  vlr_mims_tercero numeric(15,2) NOT NULL DEFAULT 0.0, -- Valor registrado en mims para pagar al tercero
  vlr_mims_propietario numeric(15,2) NOT NULL DEFAULT 0.0, -- Valor registrado en mims para descontar propietario
  estado_pago_tercero character varying(30) NOT NULL DEFAULT ''::character varying, -- Estado registrado en mims para la factura al tercero
  estado_desc_propietario character varying(30) NOT NULL DEFAULT ''::character varying, -- Estado registrado en mims para la fectara al propietario
  fecha_pago_tercero timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Fecha en que se pago al tercero
  fecha_desc_propietario timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Fecha en que se descontÃ³ al propietario
  cheque_pago_tercero character varying(15) NOT NULL DEFAULT ''::character varying, -- Cheque en que se paga al tercero
  cheque_desc_propietario character varying(15) NOT NULL DEFAULT ''::character varying, -- Cheque en que se descuenta al tercero
  corrida_pago_tercero character varying(15) NOT NULL DEFAULT ''::character varying, -- Corrida en que se paga al tercero
  corrida_desc_propietario character varying(15) NOT NULL DEFAULT ''::character varying, -- Corrida en que se descuenta al tercero
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  porcentaje numeric(5,3) NOT NULL DEFAULT 0, -- Porcentaje de descuento aplicado
  vlr_descuento moneda NOT NULL DEFAULT 0, -- Valor del  porcentaje de descuento aplicado al valor
  vlr_neto moneda NOT NULL DEFAULT 0, -- Valor menos el valor de descuento aplicado
  vlr_combancaria moneda NOT NULL DEFAULT 0, -- valor comision bancaria de acuerdo al tipo de pago
  vlr_consignacion moneda NOT NULL DEFAULT 0, -- valor a consignar
  reanticipo character varying(1) NOT NULL DEFAULT 'N'::character varying, -- Determina  si es reanticipo
  cedcon character varying(15) NOT NULL DEFAULT ''::character varying, -- Nit del conductor de la planilla
  transferencia character varying(15) NOT NULL DEFAULT ''::character varying, -- Codigo de la transacccion
  liquidacion character varying(12) NOT NULL DEFAULT ''::character varying, -- Numero de la liquidacion
  secuencia integer, -- secuencia de la transaccion en extracto
  factura_tercero character varying(8) DEFAULT ''::character varying, -- Numero de La factura de proveedor
  tipo_anticipo character varying(30) NOT NULL DEFAULT 'Fintra'::character varying, -- tipo de anticipo. Fintra o FINTRAGASOLINA
  vlr_gasolina moneda NOT NULL DEFAULT 0, -- si tipo_anticipo es FINTRAGASOLINA una parte del anticipo es para gasolina
  vlr_efectivo moneda NOT NULL DEFAULT 0, -- si tipo_anticipo es FINTRAGASOLINA una parte del anticipo es para efectivo
  enviado_fintra character varying(2) NOT NULL DEFAULT 'N'::character varying, -- se debe saber si el anticipo ya se envio a fintra o no. S o N
  fecha_envio_fintra timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- fecha en la que se envio el anticipo a fintra
  con_ant_tercero character varying(4) NOT NULL DEFAULT ''::character varying, -- Tipo de concepto para los anticipos de Fintra.
  tipo_operacion character varying(20) DEFAULT ''::character varying,
  numero_operacion character varying(20) NOT NULL DEFAULT ''::character varying,
  fecha_operacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fin.anticipos_captaciones
  OWNER TO postgres;
COMMENT ON COLUMN fin.anticipos_captaciones.id IS 'Identificador del registro';
COMMENT ON COLUMN fin.anticipos_captaciones.agency_id IS 'Agencia  que realiza el anticipo';
COMMENT ON COLUMN fin.anticipos_captaciones.pla_owner IS 'Nit del propietario de la planilla';
COMMENT ON COLUMN fin.anticipos_captaciones.planilla IS 'Numero de la planilla';
COMMENT ON COLUMN fin.anticipos_captaciones.supplier IS 'Placa';
COMMENT ON COLUMN fin.anticipos_captaciones.proveedor_anticipo IS 'Nit tercero de anticipos en planilla';
COMMENT ON COLUMN fin.anticipos_captaciones.concept_code IS 'Codigo del concepto del descuento';
COMMENT ON COLUMN fin.anticipos_captaciones.vlr IS 'Valor moneda local';
COMMENT ON COLUMN fin.anticipos_captaciones.vlr_for IS 'Valor en moneda foranea';
COMMENT ON COLUMN fin.anticipos_captaciones.currency IS 'Moneda';
COMMENT ON COLUMN fin.anticipos_captaciones.fecha_anticipo IS 'Fecha en que se grabÃ³ el anticipo';
COMMENT ON COLUMN fin.anticipos_captaciones.aprobado IS 'Indica si el anticipo es aprobado para transferir dinero';
COMMENT ON COLUMN fin.anticipos_captaciones.fecha_autorizacion IS 'Fecha en que se realizÃ³ la autorizaciÃ³n para pago anticipo';
COMMENT ON COLUMN fin.anticipos_captaciones.user_autorizacion IS 'Usuario que realizÃ³ la autorizaciÃ³n';
COMMENT ON COLUMN fin.anticipos_captaciones.transferido IS 'Indica si se realizÃ³ la transferencia del dinero';
COMMENT ON COLUMN fin.anticipos_captaciones.fecha_transferencia IS 'Fecha en que se realizÃ³ la transferencia';
COMMENT ON COLUMN fin.anticipos_captaciones.banco_transferencia IS 'Banco de la cuenta credito';
COMMENT ON COLUMN fin.anticipos_captaciones.cuenta_transferencia IS 'NÃºmero de la cuenta credito';
COMMENT ON COLUMN fin.anticipos_captaciones.tcta_transferencia IS 'Tipo de cuenta credito';
COMMENT ON COLUMN fin.anticipos_captaciones.user_transferencia IS 'Usuario que realizÃ³ la transferencia';
COMMENT ON COLUMN fin.anticipos_captaciones.banco IS 'Banco a transferir dinero';
COMMENT ON COLUMN fin.anticipos_captaciones.sucursal IS 'Sucursal banco a transferir dinero';
COMMENT ON COLUMN fin.anticipos_captaciones.nombre_cuenta IS 'Nombre cuenta a transferir dinero';
COMMENT ON COLUMN fin.anticipos_captaciones.cuenta IS 'Cuenta a transferir dinero';
COMMENT ON COLUMN fin.anticipos_captaciones.tipo_cuenta IS 'Tipo de cuenta  a transferir dinero';
COMMENT ON COLUMN fin.anticipos_captaciones.nit_cuenta IS 'Nit de la cuenta a transferir dinero';
COMMENT ON COLUMN fin.anticipos_captaciones.fecha_migracion IS 'Fecha en que se generÃ³ el archivo de migracion a mims';
COMMENT ON COLUMN fin.anticipos_captaciones.factura_mims IS 'Factura con que se sube a mims';
COMMENT ON COLUMN fin.anticipos_captaciones.vlr_mims_tercero IS 'Valor registrado en mims para pagar al tercero';
COMMENT ON COLUMN fin.anticipos_captaciones.vlr_mims_propietario IS 'Valor registrado en mims para descontar propietario';
COMMENT ON COLUMN fin.anticipos_captaciones.estado_pago_tercero IS 'Estado registrado en mims para la factura al tercero';
COMMENT ON COLUMN fin.anticipos_captaciones.estado_desc_propietario IS 'Estado registrado en mims para la fectara al propietario';
COMMENT ON COLUMN fin.anticipos_captaciones.fecha_pago_tercero IS 'Fecha en que se pago al tercero';
COMMENT ON COLUMN fin.anticipos_captaciones.fecha_desc_propietario IS 'Fecha en que se descontÃ³ al propietario';
COMMENT ON COLUMN fin.anticipos_captaciones.cheque_pago_tercero IS 'Cheque en que se paga al tercero';
COMMENT ON COLUMN fin.anticipos_captaciones.cheque_desc_propietario IS 'Cheque en que se descuenta al tercero';
COMMENT ON COLUMN fin.anticipos_captaciones.corrida_pago_tercero IS 'Corrida en que se paga al tercero';
COMMENT ON COLUMN fin.anticipos_captaciones.corrida_desc_propietario IS 'Corrida en que se descuenta al tercero';
COMMENT ON COLUMN fin.anticipos_captaciones.porcentaje IS 'Porcentaje de descuento aplicado ';
COMMENT ON COLUMN fin.anticipos_captaciones.vlr_descuento IS 'Valor del  porcentaje de descuento aplicado al valor';
COMMENT ON COLUMN fin.anticipos_captaciones.vlr_neto IS 'Valor menos el valor de descuento aplicado';
COMMENT ON COLUMN fin.anticipos_captaciones.vlr_combancaria IS 'valor comision bancaria de acuerdo al tipo de pago';
COMMENT ON COLUMN fin.anticipos_captaciones.vlr_consignacion IS 'valor a consignar';
COMMENT ON COLUMN fin.anticipos_captaciones.reanticipo IS 'Determina  si es reanticipo';
COMMENT ON COLUMN fin.anticipos_captaciones.cedcon IS 'Nit del conductor de la planilla';
COMMENT ON COLUMN fin.anticipos_captaciones.transferencia IS 'Codigo de la transacccion';
COMMENT ON COLUMN fin.anticipos_captaciones.liquidacion IS 'Numero de la liquidacion';
COMMENT ON COLUMN fin.anticipos_captaciones.secuencia IS 'secuencia de la transaccion en extracto';
COMMENT ON COLUMN fin.anticipos_captaciones.factura_tercero IS 'Numero de La factura de proveedor';
COMMENT ON COLUMN fin.anticipos_captaciones.tipo_anticipo IS 'tipo de anticipo. Fintra o FINTRAGASOLINA';
COMMENT ON COLUMN fin.anticipos_captaciones.vlr_gasolina IS 'si tipo_anticipo es FINTRAGASOLINA una parte del anticipo es para gasolina';
COMMENT ON COLUMN fin.anticipos_captaciones.vlr_efectivo IS 'si tipo_anticipo es FINTRAGASOLINA una parte del anticipo es para efectivo';
COMMENT ON COLUMN fin.anticipos_captaciones.enviado_fintra IS 'se debe saber si el anticipo ya se envio a fintra o no. S o N';
COMMENT ON COLUMN fin.anticipos_captaciones.fecha_envio_fintra IS 'fecha en la que se envio el anticipo a fintra';
COMMENT ON COLUMN fin.anticipos_captaciones.con_ant_tercero IS 'Tipo de concepto para los anticipos de Fintra.';


