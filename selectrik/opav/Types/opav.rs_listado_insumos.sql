-- Type: opav.rs_listado_insumos

-- DROP TYPE opav.rs_listado_insumos;

CREATE TYPE opav.rs_listado_insumos AS
   (insumo_adicional character varying,
    responsable character varying,
    id_solicitud character varying,
    tipo_insumo character varying,
    codigo_insumo character varying,
    descripcion_insumo character varying,
    id_unidad_medida integer,
    nombre_unidad_insumo character varying,
    insumos_total numeric,
    insumos_solicitados numeric,
    insumos_disponibles numeric,
    solicitado_temporal numeric);
ALTER TYPE opav.rs_listado_insumos
  OWNER TO postgres;
