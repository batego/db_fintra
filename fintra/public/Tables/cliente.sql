-- Table: cliente

-- DROP TABLE cliente;

CREATE TABLE cliente
(
  estado character(1) DEFAULT 'A'::bpchar,
  codcli character varying(10) NOT NULL DEFAULT ''::character varying,
  nomcli character varying(160) NOT NULL DEFAULT ''::character varying,
  notas text NOT NULL DEFAULT ''::text,
  agduenia character varying(3) NOT NULL DEFAULT 'BQ'::character varying, -- Agencia Duenia del Cliente
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying, -- Estado del Registro
  creation_date timestamp without time zone NOT NULL DEFAULT now(), -- Fecha de Creacion
  last_update timestamp without time zone NOT NULL DEFAULT now(), -- Fecha de Actualizacion
  base character varying(3) NOT NULL DEFAULT 'COL'::character varying,
  texto_oc text NOT NULL DEFAULT ''::character varying,
  nit character varying(15) DEFAULT ''::character varying,
  cedagente character varying(12) NOT NULL DEFAULT ''::character varying,
  rentabilidad numeric(5,2) NOT NULL DEFAULT 0,
  soportes_fac text NOT NULL DEFAULT ''::text, -- Soportes para Facturacion
  fiduciaria character varying(1) NOT NULL DEFAULT 'N'::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying, -- Distrito del Cliente
  moneda character varying(3) NOT NULL DEFAULT ''::character varying, -- moneda a facturar al cliente
  forma_pago character varying(15) NOT NULL DEFAULT ''::character varying, -- forma de pago
  plazo numeric(3,0) NOT NULL DEFAULT 0, -- dias a pagar
  zona character varying(6) NOT NULL DEFAULT ''::character varying, -- zona cliente
  branch_code character varying(15) NOT NULL DEFAULT ''::character varying, -- Banco de consignacion del cliente
  bank_account_no character varying(30) NOT NULL DEFAULT ''::character varying, -- Sucursal del banco de Consignacion
  cmc character varying(6) NOT NULL DEFAULT '00'::character varying, -- Codigo de manejo contable
  unidad text NOT NULL DEFAULT ''::text, -- unidad contable asociada
  codigo_impuesto character varying(6) NOT NULL DEFAULT ''::character varying, -- El codigo del impuesto que se le aplicarÃ¡ al cliente
  agfacturacion character varying(3) NOT NULL DEFAULT ''::character varying, -- Contiene codigo de la agencia de facturacion al cliente
  direccion character varying(100) NOT NULL DEFAULT ''::character varying, -- Direecion del Cliente
  telefono character varying(100) NOT NULL DEFAULT ''::character varying, -- Telefono del Cliente
  nomcontacto character varying(100) NOT NULL DEFAULT ''::character varying, -- nombre del contacto del Cliente
  telcontacto character varying(100) NOT NULL DEFAULT ''::character varying, -- telefono del contacto del Cliente
  email_contacto character varying(100) NOT NULL DEFAULT ''::character varying, -- e-mail del contacto del Cliente
  dir_factura character varying(100) NOT NULL DEFAULT ''::character varying, -- direccion de factura del Cliente
  ma_prefactura character varying(3) NOT NULL DEFAULT ''::character varying, -- direccion de factura del Cliente
  tiempoprefac character varying NOT NULL DEFAULT ''::character varying, -- Tiempo de PreFactura del Cliente
  tiempo_leg character varying NOT NULL DEFAULT ''::character varying, -- Tiempo de Legalizacion del Cliente
  tiempo_re_fact character varying NOT NULL DEFAULT ''::character varying, -- Tiempo de Revision de factura del Cliente
  diapago character varying NOT NULL DEFAULT ''::character varying, -- Dia de pago
  for_facturacion character varying(100) NOT NULL DEFAULT ''::character varying, -- direccion de factura del Cliente
  direccion_contacto character varying NOT NULL DEFAULT ''::character varying, -- Direccion del contacto del cliente
  agencia_cobro character varying(3) NOT NULL DEFAULT ''::character varying, -- Agencia de cobro
  sec_standard numeric NOT NULL DEFAULT 0,
  hc character varying(2) NOT NULL DEFAULT ''::character varying, -- codigo hcmims
  rif character varying(20) NOT NULL DEFAULT ''::character varying, -- Codigo para los cliente de ecuador o venezuela
  ciudad character varying(6) NOT NULL DEFAULT ''::character varying, -- Campo Correspondiente a la ciudad de ubicacion del cliente
  ciudad_factura character varying(3) NOT NULL DEFAULT ''::character varying, -- Campo Correspondiente a la ciudad de envio de la factura
  pais character varying(3) NOT NULL DEFAULT ''::character varying, -- Campo Correspondiente al pais del cliente
  pais_envio character varying(2) NOT NULL DEFAULT ''::character varying, -- codigo pais de envio de la factura
  agimpresion character varying(3) NOT NULL DEFAULT ''::character varying, -- Contiene codigo de la agencia de impresion de facturas al cliente
  demora_exp numeric(3,0) NOT NULL DEFAULT 0, -- Demora de exportacion en horas
  demora_imp numeric(3,0) NOT NULL DEFAULT 0, -- Demora de importacion en horas
  tipo_id character varying(3) DEFAULT ''::character varying, -- --Tipo de Identificacion ...
  dapp character varying(1) DEFAULT ''::character varying,
  nit_enviado_fiducia character varying NOT NULL DEFAULT ''::character varying,
  estado_gestion_cartera character varying(6) NOT NULL DEFAULT '01'::character varying, -- estado de gestion de cartera, ver tablagen con table_type ESTCLIENT
  nit_fiducia_actualizado character varying(1) NOT NULL DEFAULT 'N'::character varying,
  cargo_contacto character varying(50) DEFAULT ''::character varying,
  cliente_eca character varying(1) DEFAULT 'N'::character varying,
  id_ejecutivo character varying(10) DEFAULT ''::character varying,
  esoficial character varying(1) DEFAULT 'N'::character varying,
  tipo character varying(2) DEFAULT ''::character varying,
  nombre_representante character varying(160) DEFAULT ''::character varying,
  tel_representante character varying(100) DEFAULT ''::character varying,
  celular_representante character varying(15) DEFAULT ''::character varying,
  sector character varying(50) DEFAULT ''::character varying,
  creation_user character varying(50) DEFAULT ''::character varying,
  user_update character varying(50) DEFAULT ''::character varying,
  cel_contacto character varying(50) DEFAULT ''::character varying,
  edificio character varying(2) DEFAULT ''::character varying,
  tipo_cliente character varying(8) NOT NULL DEFAULT ''::character varying,
  digito_verificacion character varying(1) NOT NULL DEFAULT ''::character varying,
  observaciones character varying(500)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cliente
  OWNER TO postgres;
GRANT ALL ON TABLE cliente TO postgres;
GRANT SELECT ON TABLE cliente TO msoto;
COMMENT ON COLUMN cliente.agduenia IS 'Agencia Duenia del Cliente';
COMMENT ON COLUMN cliente.reg_status IS 'Estado del Registro';
COMMENT ON COLUMN cliente.creation_date IS 'Fecha de Creacion';
COMMENT ON COLUMN cliente.last_update IS 'Fecha de Actualizacion';
COMMENT ON COLUMN cliente.soportes_fac IS 'Soportes para Facturacion';
COMMENT ON COLUMN cliente.dstrct IS 'Distrito del Cliente';
COMMENT ON COLUMN cliente.moneda IS 'moneda a facturar al cliente';
COMMENT ON COLUMN cliente.forma_pago IS 'forma de pago';
COMMENT ON COLUMN cliente.plazo IS 'dias a pagar';
COMMENT ON COLUMN cliente.zona IS 'zona cliente';
COMMENT ON COLUMN cliente.branch_code IS 'Banco de consignacion del cliente';
COMMENT ON COLUMN cliente.bank_account_no IS 'Sucursal del banco de Consignacion';
COMMENT ON COLUMN cliente.cmc IS 'Codigo de manejo contable';
COMMENT ON COLUMN cliente.unidad IS 'unidad contable asociada';
COMMENT ON COLUMN cliente.codigo_impuesto IS 'El codigo del impuesto que se le aplicarÃ¡ al cliente';
COMMENT ON COLUMN cliente.agfacturacion IS 'Contiene codigo de la agencia de facturacion al cliente';
COMMENT ON COLUMN cliente.direccion IS 'Direecion del Cliente';
COMMENT ON COLUMN cliente.telefono IS 'Telefono del Cliente';
COMMENT ON COLUMN cliente.nomcontacto IS 'nombre del contacto del Cliente';
COMMENT ON COLUMN cliente.telcontacto IS 'telefono del contacto del Cliente';
COMMENT ON COLUMN cliente.email_contacto IS 'e-mail del contacto del Cliente';
COMMENT ON COLUMN cliente.dir_factura IS 'direccion de factura del Cliente';
COMMENT ON COLUMN cliente.ma_prefactura IS 'direccion de factura del Cliente';
COMMENT ON COLUMN cliente.tiempoprefac IS 'Tiempo de PreFactura del Cliente';
COMMENT ON COLUMN cliente.tiempo_leg IS 'Tiempo de Legalizacion del Cliente';
COMMENT ON COLUMN cliente.tiempo_re_fact IS 'Tiempo de Revision de factura del Cliente';
COMMENT ON COLUMN cliente.diapago IS 'Dia de pago';
COMMENT ON COLUMN cliente.for_facturacion IS 'direccion de factura del Cliente';
COMMENT ON COLUMN cliente.direccion_contacto IS 'Direccion del contacto del cliente';
COMMENT ON COLUMN cliente.agencia_cobro IS 'Agencia de cobro';
COMMENT ON COLUMN cliente.hc IS 'codigo hcmims';
COMMENT ON COLUMN cliente.rif IS 'Codigo para los cliente de ecuador o venezuela';
COMMENT ON COLUMN cliente.ciudad IS 'Campo Correspondiente a la ciudad de ubicacion del cliente';
COMMENT ON COLUMN cliente.ciudad_factura IS 'Campo Correspondiente a la ciudad de envio de la factura';
COMMENT ON COLUMN cliente.pais IS 'Campo Correspondiente al pais del cliente';
COMMENT ON COLUMN cliente.pais_envio IS 'codigo pais de envio de la factura';
COMMENT ON COLUMN cliente.agimpresion IS 'Contiene codigo de la agencia de impresion de facturas al cliente';
COMMENT ON COLUMN cliente.demora_exp IS 'Demora de exportacion en horas';
COMMENT ON COLUMN cliente.demora_imp IS 'Demora de importacion en horas';
COMMENT ON COLUMN cliente.tipo_id IS '--Tipo de Identificacion 
CED - Cedula
NIT  - Nit';
COMMENT ON COLUMN cliente.estado_gestion_cartera IS 'estado de gestion de cartera, ver tablagen con table_type ESTCLIENT';


-- Trigger: insertclientesonnit on cliente

-- DROP TRIGGER insertclientesonnit ON cliente;

CREATE TRIGGER insertclientesonnit
  AFTER INSERT
  ON cliente
  FOR EACH ROW
  EXECUTE PROCEDURE insertclientesonnit();


