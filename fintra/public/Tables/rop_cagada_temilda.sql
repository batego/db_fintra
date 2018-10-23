-- Table: rop_cagada_temilda

-- DROP TABLE rop_cagada_temilda;

CREATE TABLE rop_cagada_temilda
(
  id integer,
  cod_rop character varying(20),
  id_unidad_negocio integer,
  periodo_rop character varying(6),
  vencimiento_rop date,
  negocio character varying(15),
  cedula character varying(15),
  nombre_cliente character varying(100),
  direccion character varying(100),
  ciudad character varying(100),
  cuotas_vencidas character varying(20),
  cuotas_pendientes character varying(20),
  dias_vencidos character varying(20),
  fecha_ultimo_pago character varying(10),
  subtotal moneda,
  total_sanciones moneda,
  total_descuentos moneda,
  total moneda,
  total_abonos moneda,
  creation_date timestamp without time zone,
  creation_user character varying(10),
  last_update timestamp without time zone,
  user_update character varying(10),
  observacion text,
  msg_paguese_antes text,
  msg_estado_credito text,
  id_ciclo numeric,
  recibo_aplicado character varying(1),
  dstrct character varying(4)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE rop_cagada_temilda
  OWNER TO postgres;

