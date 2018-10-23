-- Table: con.sl_traslado_facturas_apoteosys_2

-- DROP TABLE con.sl_traslado_facturas_apoteosys_2;

CREATE TABLE con.sl_traslado_facturas_apoteosys_2
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
ALTER TABLE con.sl_traslado_facturas_apoteosys_2
  OWNER TO postgres;

