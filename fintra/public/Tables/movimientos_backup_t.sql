-- Table: movimientos_backup_t

-- DROP TABLE movimientos_backup_t;

CREATE TABLE movimientos_backup_t
(
  no_transaccion character varying(30),
  reg_status character varying(1),
  dstrct character varying(4),
  nit character varying(15),
  subcuenta integer,
  tasa_ea numeric,
  fecha timestamp without time zone,
  saldo_inicial moneda,
  base_intereses moneda,
  intereses moneda,
  retefuente moneda,
  reteica moneda,
  subtotal moneda,
  intereses_acomulados moneda,
  consignacion moneda,
  retiro moneda,
  saldo_final moneda,
  tipo_movimiento character varying(4),
  estado character varying(10),
  banco character varying(30),
  sucursal character varying(30),
  creation_date timestamp without time zone,
  creation_user character varying(10),
  last_update timestamp without time zone,
  user_update character varying(10),
  cuenta character varying(30),
  titular_cuenta character varying(50),
  nit_cuenta character varying(20),
  tipo_cuenta character varying(2),
  nombre_beneficiario character varying(30),
  nit_beneficiario character varying(20),
  cheque_cruzado character varying(1),
  cheque_primer_beneficiario character varying(1),
  nombre_beneficiario_cap character varying(50),
  tipo_transferencia character varying(1),
  usuario_confirmacion character varying(30),
  fecha_confirmacion timestamp without time zone,
  concepto_transaccion text
)
WITH (
  OIDS=FALSE
);
ALTER TABLE movimientos_backup_t
  OWNER TO postgres;
GRANT ALL ON TABLE movimientos_backup_t TO postgres;
GRANT SELECT ON TABLE movimientos_backup_t TO msoto;

