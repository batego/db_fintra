-- Table: opav.sl_preocs

-- DROP TABLE opav.sl_preocs;

CREATE TABLE opav.sl_preocs
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  lote_ocs character varying(20) NOT NULL DEFAULT ''::character varying,
  responsable character varying(100) NOT NULL DEFAULT ''::character varying,
  modo_compra character varying(1) NOT NULL DEFAULT ''::character varying,
  cod_solicitud character varying(50) NOT NULL DEFAULT ''::character varying,
  tipo_insumo character varying(20) NOT NULL DEFAULT ''::character varying,
  codigo_insumo character varying(20) NOT NULL DEFAULT ''::character varying,
  descripcion_insumo text NOT NULL DEFAULT ''::character varying,
  referencia_externa character varying(200) NOT NULL DEFAULT ''::character varying,
  observacion_xinsumo text DEFAULT ''::character varying,
  id_unidad_medida integer NOT NULL DEFAULT 0,
  nombre_unidad_insumo character varying(20) NOT NULL DEFAULT ''::character varying,
  cantidad_total numeric(15,4) NOT NULL DEFAULT 0,
  cantidad_solicitada numeric(15,4) NOT NULL DEFAULT 0,
  cantidad_disponible numeric(15,4) NOT NULL DEFAULT 0,
  cantidad_temporal numeric(15,4) NOT NULL DEFAULT 0,
  costo_presupuestado numeric(15,4) NOT NULL DEFAULT 0,
  costo_unitario_compra numeric(15,4) NOT NULL DEFAULT 0,
  costo_total_compra numeric(15,4) NOT NULL DEFAULT 0,
  estado_elemento integer NOT NULL DEFAULT 0,
  id_solicitud_ocs integer NOT NULL DEFAULT 0,
  estado_preocs integer NOT NULL DEFAULT 0,
  orden_cs character varying(20) NOT NULL DEFAULT ''::character varying,
  insumo_adicional character varying(1) NOT NULL DEFAULT 'N'::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_preocs
  OWNER TO postgres;
