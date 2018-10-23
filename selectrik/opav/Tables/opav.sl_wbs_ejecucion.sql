-- Table: opav.sl_wbs_ejecucion

-- DROP TABLE opav.sl_wbs_ejecucion;

CREATE TABLE opav.sl_wbs_ejecucion
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
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
  unidad_medida_apu integer NOT NULL DEFAULT 0,
  nombre_unidad_medida_apu character varying(100) NOT NULL DEFAULT ''::character varying,
  cantidad_apu numeric NOT NULL DEFAULT 0,
  cantidad_apu_actual numeric NOT NULL DEFAULT 0,
  cantidad_apu_ejecutado numeric NOT NULL DEFAULT 0,
  id_insumo integer NOT NULL DEFAULT 0,
  tipo_insumo character varying(20) NOT NULL DEFAULT ''::character varying,
  descripcion_insumo text NOT NULL DEFAULT ''::character varying,
  unidad_medida_insumo integer NOT NULL DEFAULT 0,
  nombre_unidad_insumo character varying(100) NOT NULL DEFAULT ''::character varying,
  cantidad_insumo numeric NOT NULL DEFAULT 0,
  rendimiento_insumo numeric NOT NULL DEFAULT 0,
  valor_insumo numeric NOT NULL DEFAULT 0,
  costo_personalizado numeric(19,2) NOT NULL DEFAULT 0,
  cantidad_insumo_ejecutado numeric NOT NULL DEFAULT 0,
  valor_insumo_ejecutado numeric NOT NULL DEFAULT 0,
  cantidad_insumo_actual numeric NOT NULL DEFAULT 0,
  valor_insumo_actual numeric NOT NULL DEFAULT 0,
  cantidad_insumo_total numeric NOT NULL DEFAULT 0,
  valor_insumo_total numeric NOT NULL DEFAULT 0,
  perc_contratista numeric(6,3) NOT NULL DEFAULT 0,
  valor_contratista numeric(19,2) NOT NULL DEFAULT 0,
  perc_esquema numeric(6,3) NOT NULL DEFAULT 0,
  valor_esquema numeric(19,2) NOT NULL DEFAULT 0,
  gran_total numeric NOT NULL DEFAULT 0,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  id_directorio_estados integer NOT NULL DEFAULT 0, -- este estado nos permitira saber si ese insumo se encontraba presupuestado o fue agregado en tiempo de ejecucion como un insumo adicional
  porc_avance_apu numeric(6,3) NOT NULL DEFAULT 0,
  valor_venta numeric(19,3) NOT NULL DEFAULT 0,
  cantidad_liberada numeric(15,2) NOT NULL DEFAULT 0
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_wbs_ejecucion
  OWNER TO postgres;
COMMENT ON COLUMN opav.sl_wbs_ejecucion.id_directorio_estados IS 'este estado nos permitira saber si ese insumo se encontraba presupuestado o fue agregado en tiempo de ejecucion como un insumo adicional';
