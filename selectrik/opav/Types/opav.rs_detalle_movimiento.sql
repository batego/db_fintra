-- Type: opav.rs_detalle_movimiento

-- DROP TYPE opav.rs_detalle_movimiento;

CREATE TYPE opav.rs_detalle_movimiento AS
   (codigo_insumo character varying,
    descripcion_insumo character varying,
    nombre_unidad_insumo character varying,
    referencia_externa character varying,
    cantidad numeric,
    costo_unitario_compra numeric,
    costo_total_compra numeric,
    cantidad_recibida numeric,
    costo_recibido numeric);
ALTER TYPE opav.rs_detalle_movimiento
  OWNER TO postgres;
