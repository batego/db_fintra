-- Table: egreso

-- DROP TABLE egreso;

CREATE TABLE egreso
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  branch_code character varying(15) NOT NULL DEFAULT ''::character varying,
  bank_account_no character varying(30) NOT NULL DEFAULT ''::character varying,
  document_no character varying(17) NOT NULL DEFAULT ''::character varying,
  nit character varying(15) NOT NULL DEFAULT ''::character varying,
  payment_name character varying(120) NOT NULL DEFAULT ''::character varying,
  agency_id character varying(10) NOT NULL DEFAULT ''::character varying,
  pmt_date date NOT NULL DEFAULT '0099-01-01'::date,
  printer_date date NOT NULL DEFAULT '0099-01-01'::date,
  concept_code character varying(6) NOT NULL DEFAULT ''::character varying,
  vlr numeric(15,2) NOT NULL DEFAULT 0.0,
  vlr_for numeric(15,2) NOT NULL DEFAULT 0.0,
  currency character varying(3) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  tipo_documento character varying(15) NOT NULL DEFAULT ''::character varying,
  tasa numeric(18,10) NOT NULL DEFAULT 0, -- Tasa de conversion
  fecha_cheque date NOT NULL DEFAULT '0099-01-01'::date,
  usuario_impresion character varying(15) NOT NULL DEFAULT ''::character varying,
  usuario_contabilizacion character varying(15) NOT NULL DEFAULT ''::character varying,
  fecha_contabilizacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  fecha_entrega timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  usuario_envio character varying(15) NOT NULL DEFAULT ''::character varying,
  fecha_envio timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  usuario_recibido character varying(15) NOT NULL DEFAULT ''::character varying,
  fecha_recibido timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  usuario_entrega character varying(15) NOT NULL DEFAULT ''::character varying,
  fecha_registro_entrega timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  fecha_registro_envio timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  fecha_registro_recibido timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  transaccion integer NOT NULL DEFAULT 0, -- Indica el numero de la transaccion relacionada a la contabilidad
  nit_beneficiario character varying(15) NOT NULL DEFAULT ''::character varying, -- Numero del nit del beneficiario
  fecha_reporte timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Fecha de generacion del Reporte de Egreso
  nit_proveedor character varying(15) NOT NULL DEFAULT ''::character varying, -- Nit del proveedor
  usuario_generacion character varying(10) NOT NULL DEFAULT ''::character varying, -- Usuario de generaciÃƒÆ’Ã‚Â³n del Reporte
  periodo character varying(6) NOT NULL DEFAULT ''::character varying,
  reimpresion character varying(1) NOT NULL DEFAULT 'N'::character varying, -- Permite reimprimir el cheque
  contabilizable character varying(1) NOT NULL DEFAULT ''::character varying, -- Indica si el egreso se debe contabilizar o no.
  comision numeric(7,2) NOT NULL DEFAULT 0.00,
  cuatroxmil numeric(7,2) NOT NULL DEFAULT 0.00, -- cuatro x mil
  cruce_multicash character varying(1) DEFAULT 'N'::character varying,
  archivocruce character varying(20) DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE egreso
  OWNER TO postgres;
GRANT ALL ON TABLE egreso TO postgres;
GRANT SELECT ON TABLE egreso TO msoto;
COMMENT ON COLUMN egreso.tasa IS 'Tasa de conversion';
COMMENT ON COLUMN egreso.transaccion IS 'Indica el numero de la transaccion relacionada a la contabilidad';
COMMENT ON COLUMN egreso.nit_beneficiario IS 'Numero del nit del beneficiario';
COMMENT ON COLUMN egreso.fecha_reporte IS 'Fecha de generacion del Reporte de Egreso';
COMMENT ON COLUMN egreso.nit_proveedor IS 'Nit del proveedor';
COMMENT ON COLUMN egreso.usuario_generacion IS 'Usuario de generaciÃƒÆ’Ã‚Â³n del Reporte';
COMMENT ON COLUMN egreso.reimpresion IS 'Permite reimprimir el cheque';
COMMENT ON COLUMN egreso.contabilizable IS 'Indica si el egreso se debe contabilizar o no.';
COMMENT ON COLUMN egreso.cuatroxmil IS 'cuatro x mil';


