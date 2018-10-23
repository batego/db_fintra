-- Type: opav.rs_insumos_xapu

-- DROP TYPE opav.rs_insumos_xapu;

CREATE TYPE opav.rs_insumos_xapu AS
   (responsable character varying,
    id_solicitud character varying,
    id_apu integer,
    nombre_apu text,
    tipo_insumo character varying,
    codigo_insumo character varying,
    descripcion_insumo character varying,
    id_unidad_medida integer,
    nombre_unidad_insumo character varying,
    insumos_total numeric,
    insumos_solicitados numeric,
    insumos_disponibles numeric,
    solicitado_temporal numeric);
ALTER TYPE opav.rs_insumos_xapu
  OWNER TO postgres;
