-- Table: recibo_oficial_pago

-- DROP TABLE recibo_oficial_pago;

CREATE TABLE recibo_oficial_pago
(
  id serial NOT NULL,
  cod_rop character varying(20) DEFAULT ''::character varying,
  id_unidad_negocio integer NOT NULL,
  periodo_rop character varying(6) DEFAULT '0'::character varying,
  vencimiento_rop date NOT NULL,
  negocio character varying(15) DEFAULT ''::character varying,
  cedula character varying(15) DEFAULT ''::character varying,
  nombre_cliente character varying(100) DEFAULT ''::character varying,
  direccion character varying(160) DEFAULT ''::character varying,
  ciudad character varying(100) DEFAULT ''::character varying,
  cuotas_vencidas character varying(20) DEFAULT '0'::character varying,
  cuotas_pendientes character varying(20) DEFAULT '0/0'::character varying,
  dias_vencidos character varying(20) DEFAULT '0'::character varying,
  fecha_ultimo_pago character varying(10) DEFAULT ''::text,
  subtotal moneda,
  total_sanciones moneda,
  total_descuentos moneda,
  total moneda,
  total_abonos moneda,
  creation_date timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  observacion text NOT NULL DEFAULT ''::text,
  msg_paguese_antes text NOT NULL DEFAULT ''::text,
  msg_estado_credito text NOT NULL DEFAULT ''::text,
  id_ciclo numeric,
  recibo_aplicado character varying(1) NOT NULL DEFAULT 'N'::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  duplicado character varying(1) DEFAULT 'N'::character varying,
  vencimiento_mayor character varying(50) DEFAULT ''::character varying,
  CONSTRAINT fk_recibo_oficial_pago_id FOREIGN KEY (id_unidad_negocio)
      REFERENCES unidad_negocio (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=TRUE
);
ALTER TABLE recibo_oficial_pago
  OWNER TO postgres;
GRANT ALL ON TABLE recibo_oficial_pago TO postgres;
GRANT SELECT ON TABLE recibo_oficial_pago TO msoto;

