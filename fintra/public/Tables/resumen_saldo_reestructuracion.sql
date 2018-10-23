-- Table: resumen_saldo_reestructuracion

-- DROP TABLE resumen_saldo_reestructuracion;

CREATE TABLE resumen_saldo_reestructuracion
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL,
  negocio character varying(15) NOT NULL DEFAULT ''::character varying,
  estado_cartera character varying(20) NOT NULL DEFAULT ''::character varying,
  capital numeric(11,2) NOT NULL,
  interes numeric(11,2) NOT NULL,
  intxmora numeric(11,2) NOT NULL,
  gasto_cobranza numeric(11,2) NOT NULL,
  sub_total numeric(11,2) NOT NULL,
  dcto_capital numeric(11,2) NOT NULL DEFAULT 0,
  dcto_interes numeric(11,2) NOT NULL DEFAULT 0,
  dcto_intxmora numeric(11,2) NOT NULL DEFAULT 0,
  dcto_gasto_cobranza numeric(11,2) NOT NULL DEFAULT 0,
  total_descuento numeric(11,2) NOT NULL,
  total_items numeric(11,2) NOT NULL,
  id_rop integer NOT NULL,
  user_update character varying(20) NOT NULL,
  last_update timestamp without time zone,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(20) NOT NULL,
  CONSTRAINT fk_id_rop FOREIGN KEY (id_rop)
      REFERENCES recibo_oficial_pago (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE resumen_saldo_reestructuracion
  OWNER TO postgres;
GRANT ALL ON TABLE resumen_saldo_reestructuracion TO postgres;
GRANT SELECT ON TABLE resumen_saldo_reestructuracion TO msoto;

