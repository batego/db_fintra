-- Table: opav.sl_cotizacion_detalle

-- DROP TABLE opav.sl_cotizacion_detalle;

CREATE TABLE opav.sl_cotizacion_detalle
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id_cotizacion integer NOT NULL DEFAULT 0,
  id_tipo_insumo integer NOT NULL DEFAULT 0,
  id_apu integer NOT NULL DEFAULT 0,
  id_apu_det integer NOT NULL DEFAULT 0,
  id_insumo integer NOT NULL DEFAULT 0,
  descripcion_insumo text NOT NULL DEFAULT ''::character varying,
  id_unidad_medida integer NOT NULL DEFAULT 0,
  nit_proveedor character varying(15) NOT NULL DEFAULT ''::character varying,
  cantidad numeric(19,3) NOT NULL DEFAULT 0,
  precio_predictivo numeric(19,3) DEFAULT 0,
  precio_historico numeric(19,3) DEFAULT 0,
  peso_insumo numeric(19,3) DEFAULT 0,
  precio_compra numeric(19,3) DEFAULT 0,
  perc_increm_provintegral numeric(19,3) DEFAULT 0,
  subtotal_provintegral numeric(19,3) DEFAULT 0,
  perc_increm_selectrik numeric(19,3) DEFAULT 0,
  subtotal_selectrik numeric(19,3) DEFAULT 0,
  subtotal numeric(19,3) DEFAULT 0,
  perc_descuento numeric(19,3) DEFAULT 0,
  valor_descuento numeric(19,3) DEFAULT 0,
  precio_venta numeric(19,3) DEFAULT 0,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  proveedor text NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_sl_cotizacion_detalle1 FOREIGN KEY (id_cotizacion)
      REFERENCES opav.sl_cotizacion (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_cotizacion_detalle
  OWNER TO postgres;
