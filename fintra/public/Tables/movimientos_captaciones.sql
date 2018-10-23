-- Table: movimientos_captaciones

-- DROP TABLE movimientos_captaciones;

CREATE TABLE movimientos_captaciones
(
  no_transaccion character varying(30) NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL,
  nit character varying(15) NOT NULL, -- nit del movimientos_captaciones
  subcuenta integer NOT NULL, -- Consecutivo de la subcuenta. Si es cero es el movimientos_captaciones principal.
  tasa_ea numeric DEFAULT 0, -- tasa con la cual se liquido para tener un historico de cada liquidacion de intereses
  fecha timestamp without time zone NOT NULL DEFAULT now(), -- fecha_mocimiento
  saldo_inicial moneda DEFAULT 0, -- valor de saldo inicial
  base_intereses moneda DEFAULT 0, -- Valor base interes aplica solo para interes simple
  intereses moneda DEFAULT 0, -- valor de intereses
  retefuente moneda DEFAULT 0, -- valor de retefuente
  reteica moneda DEFAULT 0, -- valor de reteica
  subtotal moneda DEFAULT 0, -- valor de reteica
  intereses_acomulados moneda DEFAULT 0, -- Valor interes_acomulado aplica para interes simple
  consignacion moneda DEFAULT 0,
  retiro moneda DEFAULT 0,
  saldo_final moneda DEFAULT 0, -- valor de saldo final
  tipo_movimiento character varying(4) NOT NULL,
  estado character varying(10) DEFAULT ''::character varying, -- estado de un movimiento cuando es retiro
  banco character varying(30) NOT NULL,
  sucursal character varying(30) NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  cuenta character varying(30) DEFAULT ''::character varying,
  titular_cuenta character varying(50) DEFAULT ''::character varying,
  nit_cuenta character varying(20) DEFAULT ''::character varying,
  tipo_cuenta character varying(2) DEFAULT ''::character varying,
  nombre_beneficiario character varying(30) DEFAULT ''::character varying,
  nit_beneficiario character varying(20) DEFAULT ''::character varying,
  cheque_cruzado character varying(1) DEFAULT ''::character varying,
  cheque_primer_beneficiario character varying(1) DEFAULT ''::character varying,
  nombre_beneficiario_cap character varying(50) DEFAULT ''::character varying,
  tipo_transferencia character varying(1) DEFAULT ''::character varying,
  usuario_confirmacion character varying(30) DEFAULT ''::character varying,
  fecha_confirmacion timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  concepto_transaccion text DEFAULT ''::text,
  procesado character varying(1) DEFAULT 'N'::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE movimientos_captaciones
  OWNER TO postgres;
GRANT ALL ON TABLE movimientos_captaciones TO postgres;
GRANT SELECT ON TABLE movimientos_captaciones TO msoto;
COMMENT ON TABLE movimientos_captaciones
  IS 'Guarda la informacion de los movimientos_captacioness de cada subcuentas';
COMMENT ON COLUMN movimientos_captaciones.nit IS 'nit del movimientos_captaciones';
COMMENT ON COLUMN movimientos_captaciones.subcuenta IS 'Consecutivo de la subcuenta. Si es cero es el movimientos_captaciones principal.';
COMMENT ON COLUMN movimientos_captaciones.tasa_ea IS 'tasa con la cual se liquido para tener un historico de cada liquidacion de intereses';
COMMENT ON COLUMN movimientos_captaciones.fecha IS 'fecha_mocimiento';
COMMENT ON COLUMN movimientos_captaciones.saldo_inicial IS 'valor de saldo inicial';
COMMENT ON COLUMN movimientos_captaciones.base_intereses IS 'Valor base interes aplica solo para interes simple';
COMMENT ON COLUMN movimientos_captaciones.intereses IS 'valor de intereses';
COMMENT ON COLUMN movimientos_captaciones.retefuente IS 'valor de retefuente';
COMMENT ON COLUMN movimientos_captaciones.reteica IS 'valor de reteica';
COMMENT ON COLUMN movimientos_captaciones.subtotal IS 'valor de reteica';
COMMENT ON COLUMN movimientos_captaciones.intereses_acomulados IS 'Valor interes_acomulado aplica para interes simple';
COMMENT ON COLUMN movimientos_captaciones.saldo_final IS 'valor de saldo final';
COMMENT ON COLUMN movimientos_captaciones.estado IS 'estado de un movimiento cuando es retiro';


