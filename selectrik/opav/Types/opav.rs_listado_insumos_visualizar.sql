-- Type: opav.rs_listado_insumos_visualizar

-- DROP TYPE opav.rs_listado_insumos_visualizar;

CREATE TYPE opav.rs_listado_insumos_visualizar AS
   (tipo_insumo character varying,
    codigo_insumo character varying,
    descripcion_insumo character varying,
    nombre_unidad_insumo character varying,
    insumos_total numeric,
    insumos_solicitados numeric,
    insumos_disponibles numeric);
ALTER TYPE opav.rs_listado_insumos_visualizar
  OWNER TO postgres;
