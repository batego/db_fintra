-- Type: opav.rs_info_presolicitud

-- DROP TYPE opav.rs_info_presolicitud;

CREATE TYPE opav.rs_info_presolicitud AS
   (tipo_solicitud integer,
    desc_tiposolicitud character varying,
    bodega integer,
    nombre_bodega character varying,
    descripcion character varying,
    fecha_actual date,
    fecha_entrega date);
ALTER TYPE opav.rs_info_presolicitud
  OWNER TO postgres;
