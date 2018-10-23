-- Table: opav.sl_relacion_cotizacion_detalle_apu

-- DROP TABLE opav.sl_relacion_cotizacion_detalle_apu;

CREATE TABLE opav.sl_relacion_cotizacion_detalle_apu
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id_cotizacion integer NOT NULL DEFAULT 0,
  id_rel_actividades_apu integer NOT NULL DEFAULT 0,
  id_apu integer NOT NULL DEFAULT 0,
  id_insumo integer NOT NULL DEFAULT 0,
  cantidad_insumo numeric NOT NULL DEFAULT 0,
  rendimiento_insumo numeric NOT NULL DEFAULT 0,
  cantidad_apu numeric NOT NULL DEFAULT 0,
  valor_insumo numeric NOT NULL DEFAULT 0,
  estado integer NOT NULL DEFAULT 0,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  costo_personalizado numeric(19,2) DEFAULT 0.00,
  perc_esquema numeric(6,3) DEFAULT 0.00,
  valor_esquema numeric(19,2) DEFAULT 0.00,
  perc_contratista numeric(6,3) DEFAULT 0.00,
  valor_contratista numeric(19,2) DEFAULT 0.00,
  gran_total numeric(19,2) DEFAULT 0.00,
  id_unidad_medida integer NOT NULL DEFAULT 0,
  valor_venta numeric(19,3) NOT NULL DEFAULT 0,
  CONSTRAINT fk_sl_relacion_cotizacion_detalle_apu1 FOREIGN KEY (id_cotizacion)
      REFERENCES opav.sl_cotizacion (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_sl_relacion_cotizacion_detalle_apu3 FOREIGN KEY (id_insumo)
      REFERENCES opav.sl_insumo (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_relacion_cotizacion_detalle_apu
  OWNER TO postgres;
