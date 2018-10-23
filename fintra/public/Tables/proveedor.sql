-- Table: proveedor

-- DROP TABLE proveedor;

CREATE TABLE proveedor
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  nit character varying(15) NOT NULL DEFAULT ''::character varying,
  id_mims character varying(10) NOT NULL DEFAULT ''::character varying,
  payment_name character varying(160) NOT NULL DEFAULT ''::character varying,
  branch_code character varying(15) NOT NULL DEFAULT ''::character varying,
  bank_account_no character varying(30) NOT NULL DEFAULT ''::character varying,
  agency_id character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  tipo_doc character varying(3) NOT NULL DEFAULT ''::character varying, -- Tipo de documento de la identificacion
  banco_transfer character varying(30) NOT NULL DEFAULT ''::character varying, -- Banco de la Transferencia
  suc_transfer character varying(15) NOT NULL DEFAULT ''::character varying, -- Sucursal de la Transferencia
  tipo_cuenta character varying(15) NOT NULL DEFAULT ''::character varying,
  no_cuenta character varying(20) NOT NULL DEFAULT ''::character varying,
  codciu_cuenta character varying(10) NOT NULL DEFAULT ''::character varying,
  clasificacion character varying(10) NOT NULL DEFAULT ''::character varying, -- Clasificacion de la identificacion personal o juridica
  gran_contribuyente character varying(2) NOT NULL DEFAULT 'N'::character varying,
  agente_retenedor character varying(2) NOT NULL DEFAULT 'N'::character varying,
  autoret_rfte character varying(2) NOT NULL DEFAULT 'N'::character varying,
  autoret_iva character varying(2) NOT NULL DEFAULT 'N'::character varying,
  autoret_ica character varying(2) NOT NULL DEFAULT 'N'::character varying,
  hc character varying(2) NOT NULL DEFAULT ''::character varying, -- codigo hcmims
  plazo numeric(3,0) NOT NULL DEFAULT 1, -- plazo para pagar
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  cedula_cuenta character varying(15) NOT NULL DEFAULT ''::character varying, -- Cedula de la cuenta del banco de la transaccion
  nombre_cuenta character varying(100) NOT NULL DEFAULT ''::character varying, -- Nombre de la Cuenta del banco de la transaccion
  concept_code character varying(6) NOT NULL DEFAULT ''::character varying, -- Codigo del concepto especifico relacionado a un proveedor
  cmc character varying(6) NOT NULL DEFAULT '00'::character varying, -- Codigo de manejo contable
  tipo_pago character varying(1) NOT NULL DEFAULT 'B'::character varying, -- Si su valor es T, el pago es por Transferencia o B, es por Banco
  nit_beneficiario character varying(15) NOT NULL DEFAULT ''::character varying, -- Numero del nit del beneficiario
  aprobado character varying(1) NOT NULL DEFAULT 'N'::character varying, -- campo que indica si esta aprobado S/N
  fecha_aprobacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Fecha que de aprobacion
  usuario_aprobacion character varying(10) NOT NULL DEFAULT ''::character varying, -- usuario que aprobo
  ret_pago character varying(1) NOT NULL DEFAULT 'N'::character varying, -- Indica si aplica retencion de pago.
  cod_fenalco character varying(20) NOT NULL DEFAULT ''::character varying, -- Codigo Fenalco
  tasa_fenalco numeric(18,10) NOT NULL DEFAULT 0, -- procentaje de cobro a clentes de fenalco
  cliente_fenalco boolean NOT NULL DEFAULT true, -- es cliente fenalco
  cliente_captacion boolean NOT NULL DEFAULT true, -- si es cliente de captaciones
  tasa_captacion numeric(18,10) NOT NULL DEFAULT 1.2, -- tasa que aplica para captacion
  frecuencia_captacion character varying(20) NOT NULL DEFAULT 'Mensual'::character varying, -- frecuancia a la cual se le aplica la tasa
  custodiacheque moneda NOT NULL DEFAULT 1450,
  remesa numeric(18,10) NOT NULL DEFAULT 0.0,
  dtsp character varying(1) DEFAULT ''::character varying,
  afiliado character varying(1) NOT NULL DEFAULT 'N'::character varying,
  sede character varying(1) NOT NULL DEFAULT 'N'::character varying,
  regimen character varying NOT NULL DEFAULT ''::character varying,
  nit_afiliado character varying NOT NULL DEFAULT ''::character varying,
  digito_verificacion character varying(1) DEFAULT ''::character varying,
  tipo_proveedor character varying(5)
)
WITH (
  OIDS=TRUE
);
ALTER TABLE proveedor
  OWNER TO postgres;
GRANT ALL ON TABLE proveedor TO postgres;
GRANT SELECT ON TABLE proveedor TO msoto;
COMMENT ON COLUMN proveedor.tipo_doc IS 'Tipo de documento de la identificacion';
COMMENT ON COLUMN proveedor.banco_transfer IS 'Banco de la Transferencia';
COMMENT ON COLUMN proveedor.suc_transfer IS 'Sucursal de la Transferencia';
COMMENT ON COLUMN proveedor.clasificacion IS 'Clasificacion de la identificacion personal o juridica';
COMMENT ON COLUMN proveedor.hc IS 'codigo hcmims';
COMMENT ON COLUMN proveedor.plazo IS 'plazo para pagar';
COMMENT ON COLUMN proveedor.cedula_cuenta IS 'Cedula de la cuenta del banco de la transaccion';
COMMENT ON COLUMN proveedor.nombre_cuenta IS 'Nombre de la Cuenta del banco de la transaccion';
COMMENT ON COLUMN proveedor.concept_code IS 'Codigo del concepto especifico relacionado a un proveedor';
COMMENT ON COLUMN proveedor.cmc IS 'Codigo de manejo contable';
COMMENT ON COLUMN proveedor.tipo_pago IS 'Si su valor es T, el pago es por Transferencia o B, es por Banco';
COMMENT ON COLUMN proveedor.nit_beneficiario IS 'Numero del nit del beneficiario';
COMMENT ON COLUMN proveedor.aprobado IS 'campo que indica si esta aprobado S/N';
COMMENT ON COLUMN proveedor.fecha_aprobacion IS 'Fecha que de aprobacion';
COMMENT ON COLUMN proveedor.usuario_aprobacion IS 'usuario que aprobo';
COMMENT ON COLUMN proveedor.ret_pago IS 'Indica si aplica retencion de pago.';
COMMENT ON COLUMN proveedor.cod_fenalco IS 'Codigo Fenalco';
COMMENT ON COLUMN proveedor.tasa_fenalco IS 'procentaje de cobro a clentes de fenalco';
COMMENT ON COLUMN proveedor.cliente_fenalco IS 'es cliente fenalco';
COMMENT ON COLUMN proveedor.cliente_captacion IS 'si es cliente de captaciones';
COMMENT ON COLUMN proveedor.tasa_captacion IS 'tasa que aplica para captacion';
COMMENT ON COLUMN proveedor.frecuencia_captacion IS 'frecuancia a la cual se le aplica la tasa';


-- Trigger: dv_insert_proveedor on proveedor

-- DROP TRIGGER dv_insert_proveedor ON proveedor;

CREATE TRIGGER dv_insert_proveedor
  AFTER INSERT
  ON proveedor
  FOR EACH ROW
  EXECUTE PROCEDURE dv_insert_proveedor();

-- Trigger: dv_update_proveedor on proveedor

-- DROP TRIGGER dv_update_proveedor ON proveedor;

CREATE TRIGGER dv_update_proveedor
  AFTER UPDATE
  ON proveedor
  FOR EACH ROW
  EXECUTE PROCEDURE dv_update_proveedor();


