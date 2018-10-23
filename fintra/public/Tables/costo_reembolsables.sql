-- Table: costo_reembolsables

-- DROP TABLE costo_reembolsables;

CREATE TABLE costo_reembolsables
(
  reg_status character(1) NOT NULL DEFAULT ''::bpchar,
  dstrct character varying(15) NOT NULL DEFAULT ''::character varying,
  codigo character varying(15) NOT NULL DEFAULT ''::character varying, -- Codigo del concepto del extraflete/costo reembolsable.
  proveedor character varying(15) NOT NULL DEFAULT ''::character varying, -- Proveedor.
  tipo_documento character varying(15) NOT NULL DEFAULT ''::character varying, -- Tipo de documento relacionado.
  documento character varying(30) NOT NULL DEFAULT ''::character varying, -- Documento relacionado.
  numrem character varying(10) NOT NULL DEFAULT ''::character varying, -- Numero de la remesa.
  numpla character varying(10) NOT NULL DEFAULT ''::character varying, -- Numero de la planilla.
  codcli character varying(6) NOT NULL DEFAULT ''::character varying, -- Codigo del cliente.
  std_job_no character varying(6) NOT NULL DEFAULT ''::character varying, -- Numero del estandar.
  element_gasto character varying(20) NOT NULL DEFAULT ''::character varying, -- Elemento del gasto.
  vlr_costo numeric(15,4) NOT NULL DEFAULT 0.0, -- Valor del costo.
  moneda_costo character varying(3) NOT NULL DEFAULT 'PES'::character varying, -- Moneda del costo.
  proveedor_costo character varying(20) NOT NULL DEFAULT ''::character varying, -- Nit del proveedor.
  fecdsp timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- fecha de despacho.
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  fecha_migracion timestamp without time zone NOT NULL DEFAULT now(), -- Fecha de migracion.
  fecha_anulacion timestamp without time zone NOT NULL DEFAULT now(), -- Fecha de anulacion.
  tipo_costo character varying(1) NOT NULL DEFAULT ''::character varying, -- Indica si es extraflete (E) o costo reembolsable (R).
  vlr_ingreso moneda, -- Valor del ingreso.
  usuario_aprobacion character varying(15) NOT NULL DEFAULT ''::character varying, -- Cedula de quien aprueba el valor del ingreso de extraflete.
  cantidad numeric(5,0) NOT NULL DEFAULT 1, -- Cantidad aplicada del concepto de extraflete o costo reembolsable
  transaccion integer NOT NULL DEFAULT 0, -- Indica el numero de la transaccion relacionada a la contabilidad
  fecha_contabilizacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Indica la fecha en que fue contabilizado el registro
  factura character varying(10) NOT NULL DEFAULT ''::character varying, -- Numero de la factura, q facturÃƒÂ³ el costo reembolable
  reembolsable character varying(1) NOT NULL DEFAULT ''::character varying, -- Indica si el costo aplicado es reembolsable (S/N)
  agencia character varying(3) NOT NULL DEFAULT ''::character varying, -- Codigo de agencia del usuario que despacha
  cuenta1 character varying(25) NOT NULL DEFAULT ''::character varying, -- Cuenta 1
  cuenta2 character varying(25) NOT NULL DEFAULT ''::character varying, -- Cuenta 2
  nit character varying(15) NOT NULL DEFAULT ''::character varying -- Nit del cliente
)
WITH (
  OIDS=TRUE
);
ALTER TABLE costo_reembolsables
  OWNER TO postgres;
GRANT ALL ON TABLE costo_reembolsables TO postgres;
GRANT SELECT ON TABLE costo_reembolsables TO msoto;
COMMENT ON TABLE costo_reembolsables
  IS 'Tabla donde se registran los costos reembolsables y los extrafletes aplicados a un despacho.';
COMMENT ON COLUMN costo_reembolsables.codigo IS 'Codigo del concepto del extraflete/costo reembolsable.';
COMMENT ON COLUMN costo_reembolsables.proveedor IS 'Proveedor.';
COMMENT ON COLUMN costo_reembolsables.tipo_documento IS 'Tipo de documento relacionado.';
COMMENT ON COLUMN costo_reembolsables.documento IS 'Documento relacionado.';
COMMENT ON COLUMN costo_reembolsables.numrem IS 'Numero de la remesa.';
COMMENT ON COLUMN costo_reembolsables.numpla IS 'Numero de la planilla.';
COMMENT ON COLUMN costo_reembolsables.codcli IS 'Codigo del cliente.';
COMMENT ON COLUMN costo_reembolsables.std_job_no IS 'Numero del estandar.';
COMMENT ON COLUMN costo_reembolsables.element_gasto IS 'Elemento del gasto.';
COMMENT ON COLUMN costo_reembolsables.vlr_costo IS 'Valor del costo.';
COMMENT ON COLUMN costo_reembolsables.moneda_costo IS 'Moneda del costo.';
COMMENT ON COLUMN costo_reembolsables.proveedor_costo IS 'Nit del proveedor.';
COMMENT ON COLUMN costo_reembolsables.fecdsp IS 'fecha de despacho.';
COMMENT ON COLUMN costo_reembolsables.fecha_migracion IS 'Fecha de migracion.';
COMMENT ON COLUMN costo_reembolsables.fecha_anulacion IS 'Fecha de anulacion.';
COMMENT ON COLUMN costo_reembolsables.tipo_costo IS 'Indica si es extraflete (E) o costo reembolsable (R).';
COMMENT ON COLUMN costo_reembolsables.vlr_ingreso IS 'Valor del ingreso.';
COMMENT ON COLUMN costo_reembolsables.usuario_aprobacion IS 'Cedula de quien aprueba el valor del ingreso de extraflete.';
COMMENT ON COLUMN costo_reembolsables.cantidad IS 'Cantidad aplicada del concepto de extraflete o costo reembolsable';
COMMENT ON COLUMN costo_reembolsables.transaccion IS 'Indica el numero de la transaccion relacionada a la contabilidad';
COMMENT ON COLUMN costo_reembolsables.fecha_contabilizacion IS 'Indica la fecha en que fue contabilizado el registro';
COMMENT ON COLUMN costo_reembolsables.factura IS 'Numero de la factura, q facturÃƒÂ³ el costo reembolable';
COMMENT ON COLUMN costo_reembolsables.reembolsable IS 'Indica si el costo aplicado es reembolsable (S/N)';
COMMENT ON COLUMN costo_reembolsables.agencia IS 'Codigo de agencia del usuario que despacha';
COMMENT ON COLUMN costo_reembolsables.cuenta1 IS 'Cuenta 1';
COMMENT ON COLUMN costo_reembolsables.cuenta2 IS 'Cuenta 2';
COMMENT ON COLUMN costo_reembolsables.nit IS 'Nit del cliente';


