-- Table: rop_cagada_temilda_detalle

-- DROP TABLE rop_cagada_temilda_detalle;

CREATE TABLE rop_cagada_temilda_detalle
(
  id integer,
  id_rop integer,
  id_conceptos_recaudo integer,
  descripcion text,
  cuota character varying(20),
  dias_vencidos integer,
  fecha_factura_padre date,
  fecha_vencimiento_padre date,
  fecha_ultimo_pago character varying(10),
  items numeric,
  valor_concepto moneda,
  valor_descuento moneda,
  valor_ixm moneda,
  valor_descuento_ixm moneda,
  valor_gac moneda,
  valor_descuento_gac moneda,
  valor_abono moneda,
  valor_saldo moneda,
  creation_date timestamp without time zone,
  creation_user character varying(10),
  negocio character varying(15),
  porcentaje_cta_inicial integer,
  dstrct character varying(4)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE rop_cagada_temilda_detalle
  OWNER TO postgres;

