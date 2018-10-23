-- Table: opav.sl_traslado_facturas_apoteosys

-- DROP TABLE opav.sl_traslado_facturas_apoteosys;

CREATE TABLE opav.sl_traslado_facturas_apoteosys
(
  id serial NOT NULL,
  id_solicitud character varying(15) NOT NULL DEFAULT ''::character varying,
  periodo character varying(6) NOT NULL DEFAULT ''::character varying,
  documento character varying(15) NOT NULL DEFAULT ''::character varying,
  traslado_selectrik character varying(1) NOT NULL DEFAULT ''::character varying,
  traslado_fintra character varying(1) NOT NULL DEFAULT ''::character varying,
  centro_costo_ingreso character varying(100) NOT NULL DEFAULT ''::character varying,
  centro_costo_gasto character varying(100) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp with time zone,
  user_update character varying(16)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_traslado_facturas_apoteosys
  OWNER TO postgres;
