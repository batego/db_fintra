-- Table: fin.prestamo

-- DROP TABLE fin.prestamo;

CREATE TABLE fin.prestamo
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  id integer NOT NULL DEFAULT nextval('fin.prestamo_id_seq'::regclass),
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying, -- El distrito
  beneficiario character varying(15) NOT NULL DEFAULT ''::character varying, -- Codigo del beneficiario o proveedor
  tercero character varying(15) NOT NULL DEFAULT ''::character varying, -- Codigo del tercero
  monto numeric(15,2) NOT NULL DEFAULT 0.00, -- Valor a prestar
  interes numeric(15,2) NOT NULL DEFAULT 0.00, -- Valor del interes total del prestamo
  cuotas numeric(3,0) NOT NULL DEFAULT 0, -- Numero de cuotas a pagar
  periodos numeric(3,0) NOT NULL DEFAULT 0, -- frecuencia  de pago que define las cuotas
  tasa numeric(6,4) NOT NULL DEFAULT 0.0000, -- tasa de interes
  tipoprestamo character varying(3) NOT NULL DEFAULT ''::character varying, -- Determina que tipo de prestamo es, esto de acuerdo a lo establecido en tabal general
  demora numeric(6,4) NOT NULL DEFAULT 0.0000, -- Interes demora
  entregadinero timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Fecha en la cual se hace entrega del dinero al beneficiario
  primercobro timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Fecha en la cual el beneficiario realiza el primer pago
  concepto character varying(10) NOT NULL DEFAULT ''::character varying, -- Concepto del prestamo
  observacion text NOT NULL DEFAULT ''::text, -- Observacion al prestamo
  ult_cuota_descontada integer NOT NULL DEFAULT 0, -- Item de la ultima cuota descontado
  fecha_ult_cuota_descontada date NOT NULL DEFAULT '0099-01-01'::date, -- Fecha de la ultima cuota descontada
  vlr_ult_cuota_descontada numeric(15,2) NOT NULL DEFAULT 0.00, -- Valor de la ultima cuota descontada
  vlracu_intdes numeric(15,2) NOT NULL DEFAULT 0.00, -- Valor acumulado intereses descontado
  vlracu_capdes numeric(15,2) NOT NULL DEFAULT 0.00, -- Valor acumulado de capital descontado
  vlracu_migmims numeric(15,2) NOT NULL DEFAULT 0.00, -- Valor acumulado que se ha migrado a mims.
  vlracu_regmims numeric(15,2) NOT NULL DEFAULT 0.00, -- Valor acumulado que se ha registrado a mims
  vlracu_desprop numeric(15,2) NOT NULL DEFAULT 0.00, -- Valor que se la ha descontado al propietario
  vlracu_pagfintra numeric(15,2) NOT NULL DEFAULT 0.00, -- valor acumulado  que tsp ha pagado a fintra
  aprobado character varying(1) NOT NULL DEFAULT 'N'::character varying, -- Determina si se aprueba o no el prestamo S o N
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  clasificacion character varying(3) NOT NULL DEFAULT ''::character varying, -- Clasificacion del prestamo
  liquidacion character varying(15) DEFAULT ''::character varying, -- Numero de la liquidacion para  prestamos de tipo pago oc
  id_prestamo_anterior integer,
  fecha_reliquidacion date DEFAULT '0099-01-01'::date,
  user_reliquidacion character varying(10) DEFAULT ''::character varying,
  placa character varying(15) NOT NULL DEFAULT ''::character varying, -- Factura monitoreo relacionada al prestamo
  equipo character varying(15) NOT NULL DEFAULT ''::character varying, -- Equipo de financiacion
  cuota_inicial moneda, -- Cuota financiacion del equipo
  cuota_financiacion moneda,
  cuota_monitoreo moneda, -- Cuota monitoreo del equipo financiado
  fecha_migracion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  factura_cuota_inicial character varying(30) NOT NULL DEFAULT ''::character varying,
  factura_financiacion character varying(30) NOT NULL DEFAULT ''::character varying,
  factura_monitoreo_inicial character varying(30) NOT NULL DEFAULT ''::character varying,
  factura_monitoreo character varying(30) NOT NULL DEFAULT ''::character varying,
  inicio_financiacion numeric(3,0) NOT NULL DEFAULT 1, -- Indicar desde que cuota se cobrara la financiacion
  inicio_monitoreo numeric(3,0) NOT NULL DEFAULT 1 -- Indicar desde que cuota se cobrara el monitoreo
)
WITH (
  OIDS=TRUE
);
ALTER TABLE fin.prestamo
  OWNER TO postgres;
COMMENT ON TABLE fin.prestamo
  IS 'Permite almacenar datos de los prestamos';
COMMENT ON COLUMN fin.prestamo.dstrct IS 'El distrito';
COMMENT ON COLUMN fin.prestamo.beneficiario IS 'Codigo del beneficiario o proveedor';
COMMENT ON COLUMN fin.prestamo.tercero IS 'Codigo del tercero';
COMMENT ON COLUMN fin.prestamo.monto IS 'Valor a prestar';
COMMENT ON COLUMN fin.prestamo.interes IS 'Valor del interes total del prestamo';
COMMENT ON COLUMN fin.prestamo.cuotas IS 'Numero de cuotas a pagar';
COMMENT ON COLUMN fin.prestamo.periodos IS 'frecuencia  de pago que define las cuotas';
COMMENT ON COLUMN fin.prestamo.tasa IS 'tasa de interes';
COMMENT ON COLUMN fin.prestamo.tipoprestamo IS 'Determina que tipo de prestamo es, esto de acuerdo a lo establecido en tabal general';
COMMENT ON COLUMN fin.prestamo.demora IS 'Interes demora';
COMMENT ON COLUMN fin.prestamo.entregadinero IS 'Fecha en la cual se hace entrega del dinero al beneficiario';
COMMENT ON COLUMN fin.prestamo.primercobro IS 'Fecha en la cual el beneficiario realiza el primer pago';
COMMENT ON COLUMN fin.prestamo.concepto IS 'Concepto del prestamo';
COMMENT ON COLUMN fin.prestamo.observacion IS 'Observacion al prestamo';
COMMENT ON COLUMN fin.prestamo.ult_cuota_descontada IS 'Item de la ultima cuota descontado';
COMMENT ON COLUMN fin.prestamo.fecha_ult_cuota_descontada IS 'Fecha de la ultima cuota descontada';
COMMENT ON COLUMN fin.prestamo.vlr_ult_cuota_descontada IS 'Valor de la ultima cuota descontada';
COMMENT ON COLUMN fin.prestamo.vlracu_intdes IS 'Valor acumulado intereses descontado';
COMMENT ON COLUMN fin.prestamo.vlracu_capdes IS 'Valor acumulado de capital descontado';
COMMENT ON COLUMN fin.prestamo.vlracu_migmims IS 'Valor acumulado que se ha migrado a mims.';
COMMENT ON COLUMN fin.prestamo.vlracu_regmims IS 'Valor acumulado que se ha registrado a mims';
COMMENT ON COLUMN fin.prestamo.vlracu_desprop IS 'Valor que se la ha descontado al propietario';
COMMENT ON COLUMN fin.prestamo.vlracu_pagfintra IS 'valor acumulado  que tsp ha pagado a fintra';
COMMENT ON COLUMN fin.prestamo.aprobado IS 'Determina si se aprueba o no el prestamo S o N ';
COMMENT ON COLUMN fin.prestamo.clasificacion IS 'Clasificacion del prestamo';
COMMENT ON COLUMN fin.prestamo.liquidacion IS 'Numero de la liquidacion para  prestamos de tipo pago oc';
COMMENT ON COLUMN fin.prestamo.placa IS 'Factura monitoreo relacionada al prestamo';
COMMENT ON COLUMN fin.prestamo.equipo IS 'Equipo de financiacion';
COMMENT ON COLUMN fin.prestamo.cuota_inicial IS 'Cuota financiacion del equipo';
COMMENT ON COLUMN fin.prestamo.cuota_monitoreo IS 'Cuota monitoreo del equipo financiado';
COMMENT ON COLUMN fin.prestamo.inicio_financiacion IS 'Indicar desde que cuota se cobrara la financiacion';
COMMENT ON COLUMN fin.prestamo.inicio_monitoreo IS 'Indicar desde que cuota se cobrara el monitoreo';


