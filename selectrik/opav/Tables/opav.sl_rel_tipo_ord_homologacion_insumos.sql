-- Table: opav.sl_rel_tipo_ord_homologacion_insumos

-- DROP TABLE opav.sl_rel_tipo_ord_homologacion_insumos;

CREATE TABLE opav.sl_rel_tipo_ord_homologacion_insumos
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  id_tipo integer,
  id_homologacion_insumo integer,
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_rel_tipo_ord_homologacion_insumos
  OWNER TO postgres;
