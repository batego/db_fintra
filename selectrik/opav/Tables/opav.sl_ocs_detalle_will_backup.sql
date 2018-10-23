-- Table: opav.sl_ocs_detalle_will_backup

-- DROP TABLE opav.sl_ocs_detalle_will_backup;

CREATE TABLE opav.sl_ocs_detalle_will_backup
(
  id integer,
  reg_status character varying(1),
  dstrct character varying(4),
  id_ocs integer,
  responsable character varying(100),
  lote_ocs character varying(20),
  cod_solicitud character varying(50),
  codigo_insumo character varying(20),
  descripcion_insumo text,
  referencia_externa character varying(200),
  observacion_xinsumo text,
  id_unidad_medida integer,
  nombre_unidad_insumo character varying(20),
  cantidad_solicitada numeric(15,4),
  costo_unitario_compra numeric(15,4),
  costo_total_compra numeric(15,4),
  insumo_adicional character varying(1),
  creation_date timestamp without time zone,
  creation_user character varying(20),
  last_update timestamp without time zone,
  user_update character varying(20)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_ocs_detalle_will_backup
  OWNER TO postgres;
