-- Table: opav.sl_relacion_cotizacion_detalle_apu_alexa

-- DROP TABLE opav.sl_relacion_cotizacion_detalle_apu_alexa;

CREATE TABLE opav.sl_relacion_cotizacion_detalle_apu_alexa
(
  id integer,
  reg_status character varying(1),
  dstrct character varying(4),
  id_cotizacion integer,
  id_rel_actividades_apu integer,
  id_apu integer,
  id_insumo integer,
  cantidad_insumo numeric,
  rendimiento_insumo numeric,
  cantidad_apu numeric,
  valor_insumo numeric,
  estado integer,
  last_update timestamp without time zone,
  user_update character varying(10),
  creation_date timestamp without time zone,
  creation_user character varying(10),
  costo_personalizado numeric(19,2),
  perc_esquema numeric(6,3),
  valor_esquema numeric(19,2),
  perc_contratista numeric(6,3),
  valor_contratista numeric(19,2),
  gran_total numeric(19,2),
  id_unidad_medida integer,
  valor_venta numeric(19,3)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_relacion_cotizacion_detalle_apu_alexa
  OWNER TO postgres;
