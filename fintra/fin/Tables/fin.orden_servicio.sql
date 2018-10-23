-- Table: fin.orden_servicio

-- DROP TABLE fin.orden_servicio;

CREATE TABLE fin.orden_servicio
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(15) NOT NULL DEFAULT ''::character varying,
  tipo_operacion character varying(20) NOT NULL DEFAULT ''::character varying,
  numero_operacion character varying(20) NOT NULL DEFAULT ''::character varying,
  proveedor character varying(15) NOT NULL DEFAULT ''::character varying,
  cmc character varying(6) NOT NULL DEFAULT ''::character varying,
  numero_transferencia character varying(15) NOT NULL DEFAULT ''::character varying,
  nombre_propietario character varying(60) NOT NULL DEFAULT ''::character varying,
  cuenta_banco character varying(15) NOT NULL DEFAULT ''::character varying,
  banco character varying(15) NOT NULL DEFAULT ''::character varying,
  sucursal character varying(30) NOT NULL DEFAULT ''::character varying,
  vlr_extracto moneda,
  porcentaje numeric(7,4) NOT NULL DEFAULT 0,
  vlr_descuento moneda,
  vlr_neto moneda,
  vlr_combancaria moneda,
  vlr_consignacion moneda,
  vlr_consignacion_calculada moneda,
  vlr_ajuste moneda,
  vlr_ext_detalle_calculado moneda,
  vlr_ext_detalle_registrado moneda,
  vlr_ext_detalle_diferencia moneda,
  vlr_diferencia_ext_ant moneda,
  last_update timestamp without time zone NOT NULL DEFAULT (now())::timestamp without time zone,
  user_update character varying NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT (now())::timestamp without time zone,
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  grupo_transaccion_os integer NOT NULL DEFAULT 0,
  periodo_os character varying(6) NOT NULL DEFAULT ''::character varying,
  fecha_contabilizacion_os timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  usuario_contabilizacion_os character varying(15) NOT NULL DEFAULT ''::character varying,
  cuenta_contable_banco character varying(25) NOT NULL DEFAULT ''::character varying,
  cuenta_os character varying(25) NOT NULL DEFAULT ''::character varying,
  dbcr_os character varying(1) NOT NULL DEFAULT ''::character varying,
  sigla_comprobante_os character varying(5) NOT NULL DEFAULT ''::character varying,
  egreso character varying(17) NOT NULL DEFAULT ''::character varying,
  fecha_egreso timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  fecha_transferencia timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  factura_cxp character varying(20) NOT NULL DEFAULT ''::character varying,
  procesado character varying(1) DEFAULT 'N'::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE fin.orden_servicio
  OWNER TO postgres;

