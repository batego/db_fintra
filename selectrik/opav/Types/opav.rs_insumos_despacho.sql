-- Type: opav.rs_insumos_despacho

-- DROP TYPE opav.rs_insumos_despacho;

CREATE TYPE opav.rs_insumos_despacho AS
   (reg_status character varying,
    id character varying,
    id_ocs character varying,
    responsable character varying,
    codigo_insumo character varying,
    descripcion_insumo character varying,
    id_unidad_medida integer,
    nombre_unidad_medida character varying,
    referencia_externa character varying,
    cantidad_solicitada numeric,
    costo_unitario_compra numeric,
    costo_total_compra numeric);
ALTER TYPE opav.rs_insumos_despacho
  OWNER TO postgres;
