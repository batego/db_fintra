-- Table: fin.descuentos_propietarios_tsp_borrados

-- DROP TABLE fin.descuentos_propietarios_tsp_borrados;

CREATE TABLE fin.descuentos_propietarios_tsp_borrados
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying, -- El distrito
  idmims character varying(6) NOT NULL DEFAULT ''::character varying, -- Codigo en mims del propietario
  nit character varying(15) NOT NULL DEFAULT ''::character varying, -- Nit del propietario
  vlr_desc numeric(6,4) NOT NULL DEFAULT 0.0000, -- Porcentaje de descuento
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  creation_date_real timestamp without time zone DEFAULT now(),
  pk_novedad integer NOT NULL,
  fecha_anulacion timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  fecha_envio_ws timestamp without time zone
)
WITH (
  OIDS=TRUE
);
ALTER TABLE fin.descuentos_propietarios_tsp_borrados
  OWNER TO postgres;
COMMENT ON COLUMN fin.descuentos_propietarios_tsp_borrados.dstrct IS 'El distrito';
COMMENT ON COLUMN fin.descuentos_propietarios_tsp_borrados.idmims IS 'Codigo en mims del propietario';
COMMENT ON COLUMN fin.descuentos_propietarios_tsp_borrados.nit IS 'Nit del propietario';
COMMENT ON COLUMN fin.descuentos_propietarios_tsp_borrados.vlr_desc IS 'Porcentaje de descuento';


