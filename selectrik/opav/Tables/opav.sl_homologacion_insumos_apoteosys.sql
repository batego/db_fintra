-- Table: opav.sl_homologacion_insumos_apoteosys

-- DROP TABLE opav.sl_homologacion_insumos_apoteosys;

CREATE TABLE opav.sl_homologacion_insumos_apoteosys
(
  id integer NOT NULL DEFAULT nextval('opav.sl_homologacion_insumos_apoteosys_id_seq'::regclass),
  id_tipo_insumo integer NOT NULL,
  aiu integer NOT NULL,
  porc_iva integer NOT NULL,
  insumo_apoteosys character varying(10) NOT NULL,
  creation_user character varying(10),
  creation_date timestamp without time zone DEFAULT now(),
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_homologacion_insumos_apoteosys
  OWNER TO postgres;
