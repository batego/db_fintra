-- Table: opav.subclientes_ofertas

-- DROP TABLE opav.subclientes_ofertas;

CREATE TABLE opav.subclientes_ofertas
(
  id_cliente character varying(10) NOT NULL DEFAULT ''::character varying,
  id_solicitud character varying(15) NOT NULL DEFAULT ''::character varying,
  porc_cuota_inicial numeric(5,2) DEFAULT 0,
  val_cuota_inicial moneda DEFAULT 0, -- indispensable
  val_cuota moneda DEFAULT 0,
  periodo numeric(2,0) DEFAULT 0, -- cantidad de cuotas
  last_update timestamp without time zone DEFAULT now(),
  creation_date character varying DEFAULT now(),
  creation_user character varying(10) DEFAULT ''::character varying,
  user_update character varying(10) DEFAULT ''::character varying,
  reg_status character varying(1) DEFAULT ''::character varying,
  nic character varying(10) DEFAULT ''::character varying,
  tasa numeric(5,2) DEFAULT 0,
  valor_base moneda DEFAULT 0, -- valor establecido incialmente como el que va a ser financiado, a menos que haya cuota inicial y/o anticipos
  estudio_economico character varying(50) DEFAULT 'OPAV'::character varying, -- parece ser una constante que determina algo asociado a la financiacion pero todavia no se sabe la trascendencia de este campo
  porc_base numeric(6,3) DEFAULT 0,
  fecha_financiacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  parcial integer NOT NULL DEFAULT 1,
  tipo_punto character varying(10) NOT NULL DEFAULT ''::character varying,
  clase_dtf character varying(30) NOT NULL DEFAULT ''::character varying,
  punto numeric(6,3) NOT NULL DEFAULT 0.00,
  dtf_semanal numeric(6,3) NOT NULL DEFAULT 0.00,
  val_sin_iva moneda NOT NULL DEFAULT 0.00,
  porcentaje_base numeric(5,2) NOT NULL DEFAULT 0.00,
  base_1 moneda NOT NULL DEFAULT 0.00,
  porcentaje_incremento numeric(6,3) NOT NULL DEFAULT 0.00,
  porcentaje_extemporaneo numeric(7,5) NOT NULL DEFAULT 0.00,
  val_extemporaneo_1 moneda NOT NULL DEFAULT 0.00,
  base_2 moneda NOT NULL DEFAULT 0.00,
  base_3 moneda NOT NULL DEFAULT 0.00,
  iva moneda NOT NULL DEFAULT 0.00,
  iva_base moneda NOT NULL DEFAULT 0.00,
  val_extemporaneo_2 moneda NOT NULL DEFAULT 0.00,
  subtotal_iva moneda NOT NULL DEFAULT 0.00,
  val_a_financiar moneda NOT NULL DEFAULT 0.00,
  intereses moneda NOT NULL DEFAULT 0.00,
  val_con_financiacion moneda NOT NULL DEFAULT 0.00,
  cuota_pago moneda NOT NULL DEFAULT 0.00,
  porcentaje_interes numeric(6,3) NOT NULL DEFAULT 0.00,
  prefacturar character varying(1) NOT NULL DEFAULT 'N'::character varying,
  factura_cliente character varying(15) NOT NULL DEFAULT ''::character varying,
  simbolo_variable text NOT NULL DEFAULT ''::text,
  observacion text NOT NULL DEFAULT ''::text,
  fecha_factura date NOT NULL DEFAULT '0099-01-01'::date, -- temporalmente la fecha en que se subiÃ³n en open
  fecha_inicio_pago date NOT NULL DEFAULT '0099-01-01'::date, -- Fecha en la cual el cliente paga su primera factura. Se calculan intereses adicionales desde la fecha de fecha de factura hasta esta fecha
  factura_cuota_inicial character varying(15) NOT NULL DEFAULT ''::character varying,
  tipo character varying(10) DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  corte integer NOT NULL DEFAULT 1
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.subclientes_ofertas
  OWNER TO postgres;
COMMENT ON COLUMN opav.subclientes_ofertas.val_cuota_inicial IS 'indispensable';
COMMENT ON COLUMN opav.subclientes_ofertas.periodo IS 'cantidad de cuotas';
COMMENT ON COLUMN opav.subclientes_ofertas.valor_base IS 'valor establecido incialmente como el que va a ser financiado, a menos que haya cuota inicial y/o anticipos';
COMMENT ON COLUMN opav.subclientes_ofertas.estudio_economico IS 'parece ser una constante que determina algo asociado a la financiacion pero todavia no se sabe la trascendencia de este campo ';
COMMENT ON COLUMN opav.subclientes_ofertas.fecha_factura IS 'temporalmente la fecha en que se subiÃ³n en open';
COMMENT ON COLUMN opav.subclientes_ofertas.fecha_inicio_pago IS 'Fecha en la cual el cliente paga su primera factura. Se calculan intereses adicionales desde la fecha de fecha de factura hasta esta fecha';


-- Trigger: hsubclientes_oferta on opav.subclientes_ofertas

-- DROP TRIGGER hsubclientes_oferta ON opav.subclientes_ofertas;

CREATE TRIGGER hsubclientes_oferta
  AFTER INSERT OR UPDATE
  ON opav.subclientes_ofertas
  FOR EACH ROW
  EXECUTE PROCEDURE insert_h_subclof();
