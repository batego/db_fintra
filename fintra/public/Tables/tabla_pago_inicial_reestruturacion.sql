-- Table: tabla_pago_inicial_reestruturacion

-- DROP TABLE tabla_pago_inicial_reestruturacion;

CREATE TABLE tabla_pago_inicial_reestruturacion
(
  id serial NOT NULL,
  dstrct character varying(6) NOT NULL DEFAULT ''::character varying,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  id_rop integer NOT NULL,
  negocio character varying(15) NOT NULL,
  tipo_negocio character varying(20) NOT NULL DEFAULT ''::character varying,
  capital numeric(11,2) NOT NULL DEFAULT 0,
  interes numeric(11,2) NOT NULL DEFAULT 0,
  intx_mora numeric(11,2) NOT NULL DEFAULT 0,
  gac numeric(11,2) NOT NULL DEFAULT 0,
  total numeric(11,2) NOT NULL DEFAULT 0,
  pct_pagar numeric(11,2) NOT NULL DEFAULT 0,
  valor_pagar numeric(11,2) NOT NULL DEFAULT 0,
  saldo_vencido numeric(11,2) NOT NULL DEFAULT 0,
  saldo_corriente numeric(11,2) NOT NULL DEFAULT 0,
  usuario_aprobacion character varying(20) NOT NULL DEFAULT ''::character varying,
  aprobado character varying(1) NOT NULL DEFAULT 'N'::character varying,
  creation_user character varying(20) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  impreso character varying(1) NOT NULL DEFAULT 'N'::character varying,
  user_impresion character varying(20) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_id_rop_tabla_inicial FOREIGN KEY (id_rop)
      REFERENCES recibo_oficial_pago (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tabla_pago_inicial_reestruturacion
  OWNER TO postgres;
GRANT ALL ON TABLE tabla_pago_inicial_reestruturacion TO postgres;
GRANT SELECT ON TABLE tabla_pago_inicial_reestruturacion TO msoto;

