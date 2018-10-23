-- Table: opav.sl_lote_ejecucion_detalle

-- DROP TABLE opav.sl_lote_ejecucion_detalle;

CREATE TABLE opav.sl_lote_ejecucion_detalle
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id_lote_ejecucion integer NOT NULL DEFAULT 1,
  id_directorio_estados integer NOT NULL DEFAULT 1,
  id_solicitud integer NOT NULL DEFAULT 0,
  id_area integer NOT NULL DEFAULT 0,
  id_disciplina integer NOT NULL DEFAULT 0,
  id_disciplina_area integer NOT NULL DEFAULT 0,
  id_capitulo integer NOT NULL DEFAULT 0,
  id_actividad integer NOT NULL DEFAULT 0,
  id_actividades_capitulo integer NOT NULL DEFAULT 0,
  id_rel_actividades_apu integer NOT NULL DEFAULT 0,
  id_relacion_cotizacion_detalle_apu integer NOT NULL DEFAULT 0,
  id_cotizacion integer NOT NULL DEFAULT 0,
  id_apu integer NOT NULL DEFAULT 0,
  unidad_medida_apu character varying(100) NOT NULL DEFAULT ''::character varying,
  nombre_unidad_medida_apu character varying(100) NOT NULL DEFAULT ''::character varying,
  cantidad_apu numeric(9,3) NOT NULL DEFAULT 0,
  cantidad_apu_aprobado numeric(9,3) NOT NULL DEFAULT 0,
  id_insumo integer NOT NULL DEFAULT 0,
  tipo_insumo character varying(100) NOT NULL DEFAULT ''::character varying,
  descripcion_insumo character varying(200) NOT NULL DEFAULT ''::character varying,
  unidad_medida_insumo integer NOT NULL DEFAULT 0,
  nombre_unidad_insumo character varying(200) NOT NULL DEFAULT ''::character varying,
  cantidad_insumo numeric(6,3) NOT NULL DEFAULT 0,
  rendimiento_insumo numeric(6,3) NOT NULL DEFAULT 0,
  valor_insumo numeric(15,4) NOT NULL DEFAULT 0,
  costo_personalizado numeric(15,4) NOT NULL DEFAULT 0,
  cantidad_insumo_total numeric NOT NULL DEFAULT 0,
  valor_insumo_total numeric NOT NULL DEFAULT 0,
  perc_contratista numeric(6,3) NOT NULL DEFAULT 0,
  valor_contratista numeric(15,4) NOT NULL DEFAULT 0,
  perc_esquema numeric(6,3) NOT NULL DEFAULT 0,
  valor_esquema numeric NOT NULL DEFAULT 0,
  gran_total numeric NOT NULL DEFAULT 0,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  porc_avance_apu numeric(6,3) NOT NULL DEFAULT 0,
  valor_venta numeric(19,3) NOT NULL DEFAULT 0,
  CONSTRAINT fk_sl_lote_ejecucion_detalle1 FOREIGN KEY (id_lote_ejecucion)
      REFERENCES opav.sl_lote_ejecucion (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_lote_ejecucion_detalle
  OWNER TO postgres;
