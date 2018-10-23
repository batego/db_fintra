-- Table: con.sl_traslado_facturas_apoteosys

-- DROP TABLE con.sl_traslado_facturas_apoteosys;

CREATE TABLE con.sl_traslado_facturas_apoteosys
(
  id numeric,
  id_solicitud character varying,
  centro_costo_ingreso character varying,
  centro_costo_gasto character varying,
  documento character varying,
  traslado_selectrik character varying,
  traslado_fintra character varying,
  descripcion character varying,
  periodo character varying,
  num_os character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.sl_traslado_facturas_apoteosys
  OWNER TO postgres;

