-- Table: detalle_rop

-- DROP TABLE detalle_rop;

CREATE TABLE detalle_rop
(
  id serial NOT NULL,
  id_rop integer NOT NULL,
  id_conceptos_recaudo integer NOT NULL,
  descripcion text NOT NULL DEFAULT ''::text,
  cuota character varying(20) DEFAULT '0'::character varying,
  dias_vencidos integer NOT NULL,
  fecha_factura_padre date NOT NULL,
  fecha_vencimiento_padre date NOT NULL,
  fecha_ultimo_pago character varying(10) DEFAULT ''::text,
  items numeric NOT NULL DEFAULT 0,
  valor_concepto moneda,
  valor_descuento moneda,
  valor_ixm moneda,
  valor_descuento_ixm moneda,
  valor_gac moneda,
  valor_descuento_gac moneda,
  valor_abono moneda,
  valor_saldo moneda,
  creation_date timestamp without time zone NOT NULL,
  creation_user character varying(10) NOT NULL,
  negocio character varying(15) DEFAULT ''::character varying,
  porcentaje_cta_inicial integer NOT NULL DEFAULT 0,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_id_rop FOREIGN KEY (id_rop)
      REFERENCES recibo_oficial_pago (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=TRUE
);
ALTER TABLE detalle_rop
  OWNER TO postgres;
GRANT ALL ON TABLE detalle_rop TO postgres;
GRANT SELECT ON TABLE detalle_rop TO msoto;

