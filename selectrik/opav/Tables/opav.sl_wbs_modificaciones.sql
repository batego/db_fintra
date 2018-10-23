-- Table: opav.sl_wbs_modificaciones

-- DROP TABLE opav.sl_wbs_modificaciones;

CREATE TABLE opav.sl_wbs_modificaciones
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  no_lote character varying(10),
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
  id_insumo integer NOT NULL DEFAULT 0,
  tipo_insumo character varying(100) NOT NULL DEFAULT ''::character varying,
  descripcion_insumo character varying(200) NOT NULL DEFAULT ''::character varying,
  unidad_medida_insumo integer NOT NULL DEFAULT 0,
  nombre_unidad_insumo character varying(200) NOT NULL DEFAULT ''::character varying,
  cantidad_apu numeric(9,3) NOT NULL DEFAULT 0,
  cantidad_insumo numeric(6,3) NOT NULL DEFAULT 0,
  rendimiento_insumo numeric(6,3) NOT NULL DEFAULT 0,
  costo_personalizado numeric(15,4) NOT NULL DEFAULT 0,
  cantidad_insumo_total numeric NOT NULL DEFAULT 0,
  movimiento character varying(10) NOT NULL DEFAULT ''::character varying,
  valor_insumo_total numeric NOT NULL DEFAULT 0,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_wbs_modificaciones
  OWNER TO postgres;
