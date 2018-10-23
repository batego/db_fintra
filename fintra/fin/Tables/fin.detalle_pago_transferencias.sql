-- Table: fin.detalle_pago_transferencias

-- DROP TABLE fin.detalle_pago_transferencias;

CREATE TABLE fin.detalle_pago_transferencias
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  banco_transfer character varying(30) NOT NULL DEFAULT ''::character varying, -- Banco que paga la transferencia
  suc_transfer character varying(30) NOT NULL DEFAULT ''::character varying, -- Sucursal del banco de pago
  transferencia character varying(30) NOT NULL DEFAULT ''::character varying, -- NÃºmero de la transferencia
  cheque character varying(15) NOT NULL DEFAULT ''::character varying, -- NÃºmero de cheque con que se paga
  banco_cuenta character varying(30) NOT NULL DEFAULT ''::character varying, -- Banco de la cta del propietario
  tipo_cuenta character varying(3) NOT NULL DEFAULT ''::character varying,
  no_cuenta character varying(20) NOT NULL DEFAULT ''::character varying,
  cedula_cuenta character varying(15) NOT NULL DEFAULT ''::character varying,
  nombre_cuenta character varying(100) NOT NULL DEFAULT ''::character varying,
  valor moneda, -- Valor a pagar
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  tipo_pago character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fin.detalle_pago_transferencias
  OWNER TO postgres;
COMMENT ON TABLE fin.detalle_pago_transferencias
  IS 'Tabla para almacenar el detalle de las transferencia de pago';
COMMENT ON COLUMN fin.detalle_pago_transferencias.banco_transfer IS 'Banco que paga la transferencia';
COMMENT ON COLUMN fin.detalle_pago_transferencias.suc_transfer IS 'Sucursal del banco de pago';
COMMENT ON COLUMN fin.detalle_pago_transferencias.transferencia IS 'NÃºmero de la transferencia';
COMMENT ON COLUMN fin.detalle_pago_transferencias.cheque IS 'NÃºmero de cheque con que se paga';
COMMENT ON COLUMN fin.detalle_pago_transferencias.banco_cuenta IS 'Banco de la cta del propietario';
COMMENT ON COLUMN fin.detalle_pago_transferencias.valor IS 'Valor a pagar';


