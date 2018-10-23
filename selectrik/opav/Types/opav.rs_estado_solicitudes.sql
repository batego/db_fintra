-- Type: opav.rs_estado_solicitudes

-- DROP TYPE opav.rs_estado_solicitudes;

CREATE TYPE opav.rs_estado_solicitudes AS
   (nombre_proyecto character varying,
    estado_solicitud character varying);
ALTER TYPE opav.rs_estado_solicitudes
  OWNER TO postgres;
