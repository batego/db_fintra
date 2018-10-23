-- Table: movpla

-- DROP TABLE movpla;

CREATE TABLE movpla
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  agency_id character varying(10) NOT NULL DEFAULT ''::character varying,
  document_type character varying(4) NOT NULL DEFAULT ''::character varying,
  document character varying(12) NOT NULL DEFAULT ''::character varying, -- No. Cheque o Egreso
  item character varying(4) NOT NULL DEFAULT ''::character varying, -- Item del egreso en este caso cuando en el egreso se especifican mas de un valor
  concept_code character varying(12) NOT NULL DEFAULT ''::character varying, -- Codigo del concepto del descuento.
  pla_owner character varying(15) NOT NULL DEFAULT ''::character varying, -- Nit del propietario de la planilla
  planilla character varying(10) NOT NULL DEFAULT ''::character varying, -- Numero del documento
  supplier character varying(10) NOT NULL DEFAULT ''::character varying,
  date_doc date NOT NULL DEFAULT '0099-01-01'::date,
  applicated_ind character varying(1) NOT NULL DEFAULT ''::character varying, -- S/N
  application_ind character varying(1) NOT NULL DEFAULT ''::character varying, -- Indica si se aplica al Valor o al Saldo S/V
  ind_vlr character varying(1) NOT NULL DEFAULT ''::character varying, -- Indica si es porcentaje o valor
  vlr_disc numeric(15,4) NOT NULL DEFAULT 0.0, -- Valor Del descuento
  vlr numeric(15,2) NOT NULL DEFAULT 0.0, -- Valor a aplicar
  vlr_for numeric(15,2) NOT NULL DEFAULT 0.0, -- Valor en moneda foranea
  currency character varying(3) NOT NULL DEFAULT ''::character varying, -- Moneda
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  proveedor_anticipo character varying(15) NOT NULL DEFAULT ''::character varying, -- Nit del que da anticipos en planilla
  sucursal character varying(15) NOT NULL DEFAULT ''::character varying, -- Sucursal del intermediario que entrega el anticipo
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  corte timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  branch_code character varying(15) NOT NULL DEFAULT ''::character varying,
  bank_account_no character varying(30) NOT NULL DEFAULT ''::character varying,
  fech_anul timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_anul character varying(10) NOT NULL DEFAULT ''::character varying,
  ch_remplazo character varying(12) NOT NULL DEFAULT ''::character varying,
  branch_code_remplazo character varying(15) NOT NULL DEFAULT ''::character varying,
  bank_account_no_remplazo character varying(30) NOT NULL DEFAULT ''::character varying,
  fecha_cheque timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  fecha_migracion date NOT NULL DEFAULT '0099-01-01'::date,
  cantidad numeric(5,0) NOT NULL DEFAULT 0,
  reanticipo character varying(1) NOT NULL DEFAULT 'N'::character varying,
  transaccion integer NOT NULL DEFAULT 0, -- Indica el numero de la transaccion relacionada a la contabilidad
  fecha_contabilizacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Indica la fecha en que fue contabilizado el registro
  factura character varying(30) DEFAULT ''::character varying, -- Numero de la factura del proveedor
  periodo character varying(6) NOT NULL DEFAULT ''::character varying, -- Periodo
  beneficiario character varying(15) NOT NULL DEFAULT ''::character varying, -- Define el nit del beneficiario del cheque del anticipo
  tercero character varying(1) NOT NULL DEFAULT ''::character varying, -- Indica si es pagado por un tercero
  fecha_migracion1 date NOT NULL DEFAULT '0099-01-01'::date, -- Fecha para la migracion de cheques
  factura_tercero character varying(8) NOT NULL DEFAULT ''::character varying -- Numero de La factura de proveedor
)
WITH (
  OIDS=TRUE
);
ALTER TABLE movpla
  OWNER TO postgres;
GRANT ALL ON TABLE movpla TO postgres;
GRANT SELECT ON TABLE movpla TO msoto;
COMMENT ON COLUMN movpla.document IS 'No. Cheque o Egreso';
COMMENT ON COLUMN movpla.item IS 'Item del egreso en este caso cuando en el egreso se especifican mas de un valor';
COMMENT ON COLUMN movpla.concept_code IS 'Codigo del concepto del descuento.';
COMMENT ON COLUMN movpla.pla_owner IS 'Nit del propietario de la planilla';
COMMENT ON COLUMN movpla.planilla IS 'Numero del documento';
COMMENT ON COLUMN movpla.applicated_ind IS 'S/N ';
COMMENT ON COLUMN movpla.application_ind IS 'Indica si se aplica al Valor o al Saldo S/V';
COMMENT ON COLUMN movpla.ind_vlr IS 'Indica si es porcentaje o valor';
COMMENT ON COLUMN movpla.vlr_disc IS 'Valor Del descuento';
COMMENT ON COLUMN movpla.vlr IS 'Valor a aplicar';
COMMENT ON COLUMN movpla.vlr_for IS 'Valor en moneda foranea';
COMMENT ON COLUMN movpla.currency IS 'Moneda';
COMMENT ON COLUMN movpla.proveedor_anticipo IS 'Nit del que da anticipos en planilla';
COMMENT ON COLUMN movpla.sucursal IS 'Sucursal del intermediario que entrega el anticipo';
COMMENT ON COLUMN movpla.transaccion IS 'Indica el numero de la transaccion relacionada a la contabilidad';
COMMENT ON COLUMN movpla.fecha_contabilizacion IS 'Indica la fecha en que fue contabilizado el registro';
COMMENT ON COLUMN movpla.factura IS 'Numero de la factura del proveedor';
COMMENT ON COLUMN movpla.periodo IS 'Periodo';
COMMENT ON COLUMN movpla.beneficiario IS 'Define el nit del beneficiario del cheque del anticipo';
COMMENT ON COLUMN movpla.tercero IS 'Indica si es pagado por un tercero';
COMMENT ON COLUMN movpla.fecha_migracion1 IS 'Fecha para la migracion de cheques';
COMMENT ON COLUMN movpla.factura_tercero IS 'Numero de La factura de proveedor';


