-- Table: fin.amortizaciones

-- DROP TABLE fin.amortizaciones;

CREATE TABLE fin.amortizaciones
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying, -- Estado del registro
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying, -- Distrito
  prestamo numeric(10,0) NOT NULL, -- Codigo del prestamo
  item numeric(3,0) NOT NULL, -- Cuota
  beneficiario character varying(15) NOT NULL DEFAULT ''::character varying, -- Persona que recibe el dinero
  tercero character varying(15) NOT NULL DEFAULT ''::character varying, -- Tercero, persona que da el dinero
  fecha_pago date NOT NULL DEFAULT '0099-01-01'::date, -- fecha de pago
  valor_monto moneda NOT NULL DEFAULT 0, -- Monto Inicial de la amortizacion
  valor_a_pagar moneda NOT NULL DEFAULT 0, -- Valor a pagar
  valor_capital moneda NOT NULL DEFAULT 0, -- Valor de capital del valor real pagado
  valor_interes moneda NOT NULL DEFAULT 0, -- Valor de interes del valor real pagado
  valor_saldo moneda NOT NULL DEFAULT 0, -- Saldo de la Amortizacion
  fecha_descuento date NOT NULL DEFAULT '0099-01-01'::date,
  valor_descuento moneda NOT NULL DEFAULT 0,
  banco_descuento character varying(40) NOT NULL DEFAULT ''::character varying,
  sucursal_descuento character varying(40) NOT NULL DEFAULT ''::character varying,
  cheque_descuento character varying(30) NOT NULL DEFAULT ''::character varying,
  corrida_descuento character varying(30) NOT NULL DEFAULT ''::character varying,
  estado_descuento character varying(30) NOT NULL DEFAULT ''::character varying,
  fecha_pago_ter date NOT NULL DEFAULT '0099-01-01'::date,
  valor_pago_ter moneda NOT NULL DEFAULT 0,
  banco_pago_ter character varying(40) NOT NULL DEFAULT ''::character varying,
  sucursal_pago_ter character varying(40) NOT NULL DEFAULT ''::character varying,
  cheque_pago_ter character varying(30) NOT NULL DEFAULT ''::character varying,
  corrida_pago_ter character varying(30) NOT NULL DEFAULT ''::character varying,
  estado_pago_ter character varying(30) NOT NULL DEFAULT ''::character varying,
  fecha_transferencia timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Fecha transferencia a mims
  usuario_tranferencia character varying(40) NOT NULL DEFAULT ''::character varying, -- Usuario transferencia a mims
  creation_user character varying(40) NOT NULL DEFAULT ''::character varying, -- Usuario creacion
  creation_date timestamp without time zone NOT NULL DEFAULT now(), -- Fecha de ceacion
  user_update character varying(40) NOT NULL DEFAULT ''::character varying, -- Usuario ultima modificacion
  last_update timestamp without time zone NOT NULL DEFAULT now(), -- Ultima modificacion
  base character varying(3) NOT NULL DEFAULT ''::character varying, -- Base
  observacion text DEFAULT ''::text,
  referencia text NOT NULL DEFAULT ''::text -- Otras referencias relacionadas a las cuotas.
)
WITH (
  OIDS=TRUE
);
ALTER TABLE fin.amortizaciones
  OWNER TO postgres;
COMMENT ON TABLE fin.amortizaciones
  IS 'Almacena las amortizaciones de los prestamos aprobados';
COMMENT ON COLUMN fin.amortizaciones.reg_status IS 'Estado del registro';
COMMENT ON COLUMN fin.amortizaciones.dstrct IS 'Distrito';
COMMENT ON COLUMN fin.amortizaciones.prestamo IS 'Codigo del prestamo';
COMMENT ON COLUMN fin.amortizaciones.item IS 'Cuota';
COMMENT ON COLUMN fin.amortizaciones.beneficiario IS 'Persona que recibe el dinero';
COMMENT ON COLUMN fin.amortizaciones.tercero IS 'Tercero, persona que da el dinero';
COMMENT ON COLUMN fin.amortizaciones.fecha_pago IS 'fecha de pago';
COMMENT ON COLUMN fin.amortizaciones.valor_monto IS 'Monto Inicial de la amortizacion';
COMMENT ON COLUMN fin.amortizaciones.valor_a_pagar IS 'Valor a pagar';
COMMENT ON COLUMN fin.amortizaciones.valor_capital IS 'Valor de capital del valor real pagado';
COMMENT ON COLUMN fin.amortizaciones.valor_interes IS 'Valor de interes del valor real pagado';
COMMENT ON COLUMN fin.amortizaciones.valor_saldo IS 'Saldo de la Amortizacion';
COMMENT ON COLUMN fin.amortizaciones.fecha_transferencia IS 'Fecha transferencia a mims';
COMMENT ON COLUMN fin.amortizaciones.usuario_tranferencia IS 'Usuario transferencia a mims';
COMMENT ON COLUMN fin.amortizaciones.creation_user IS 'Usuario creacion';
COMMENT ON COLUMN fin.amortizaciones.creation_date IS 'Fecha de ceacion';
COMMENT ON COLUMN fin.amortizaciones.user_update IS 'Usuario ultima modificacion';
COMMENT ON COLUMN fin.amortizaciones.last_update IS 'Ultima modificacion';
COMMENT ON COLUMN fin.amortizaciones.base IS 'Base';
COMMENT ON COLUMN fin.amortizaciones.referencia IS 'Otras referencias relacionadas a las cuotas.';


