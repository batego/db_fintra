-- Table: opav.sl_sl_despacho_detalle_will_backup

-- DROP TABLE opav.sl_sl_despacho_detalle_will_backup;

CREATE TABLE opav.sl_sl_despacho_detalle_will_backup
(
  id integer,
  reg_status character varying(1),
  dstrct character varying(4),
  id_despacho integer,
  id_ocs_detalle integer,
  responsable character varying(100),
  codigo_insumo character varying(20),
  descripcion_insumo text,
  referencia_externa character varying(200),
  id_unidad_medida integer,
  nombre_unidad_insumo character varying(20),
  cantidad_recibida numeric(15,4),
  costo_unitario_recibido numeric(15,4),
  costo_total_recibido numeric(15,4),
  creation_date timestamp without time zone,
  creation_user character varying(20),
  last_update timestamp without time zone,
  user_update character varying(20)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_sl_despacho_detalle_will_backup
  OWNER TO postgres;
