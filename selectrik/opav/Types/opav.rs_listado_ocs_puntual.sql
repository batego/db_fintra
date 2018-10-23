-- Type: opav.rs_listado_ocs_puntual

-- DROP TYPE opav.rs_listado_ocs_puntual;

CREATE TYPE opav.rs_listado_ocs_puntual AS
   (codigo_insumo character varying,
    descripcion_insumo character varying,
    id_unidad_medida integer,
    nombre_unidad_insumo character varying,
    referencia_externa character varying,
    cantidad_solicitada numeric,
    costo_unitario_compra numeric,
    costo_total_compra numeric);
ALTER TYPE opav.rs_listado_ocs_puntual
  OWNER TO postgres;
