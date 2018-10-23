-- Table: opav.sl_compra_material

-- DROP TABLE opav.sl_compra_material;

CREATE TABLE opav.sl_compra_material
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id_solicitud integer,
  id_tipo_insumo integer,
  id_insumo integer,
  cantidad numeric(14,2),
  costo numeric(14,2),
  id_unidad_medida integer,
  fecha_com date,
  criticidad character varying(15) DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_compra_material
  OWNER TO postgres;
