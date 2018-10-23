-- Type: opav.rs_insumos_ocs

-- DROP TYPE opav.rs_insumos_ocs;

CREATE TYPE opav.rs_insumos_ocs AS
   (insumo_adicional character varying,
    responsable character varying,
    cod_solicitud character varying,
    tipo_insumo character varying,
    codigo_insumo character varying,
    descripcion_insumo character varying,
    id_unidad_medida integer,
    nombre_unidad_medida character varying,
    referencia_externa character varying,
    cantidad_total numeric,
    cantidad_solicitada numeric,
    cantidad_disponible numeric,
    cantidad_temporal numeric,
    costo_presupuestado numeric);
ALTER TYPE opav.rs_insumos_ocs
  OWNER TO postgres;
