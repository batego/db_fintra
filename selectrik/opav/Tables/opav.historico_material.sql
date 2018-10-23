-- Table: opav.historico_material

-- DROP TABLE opav.historico_material;

CREATE TABLE opav.historico_material
(
  id serial NOT NULL,
  cod_material character varying(15) NOT NULL DEFAULT ''::character varying,
  fecha_actualizacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  precio_actualizado character varying(1) NOT NULL DEFAULT 'N'::character varying,
  user_update character varying(15) NOT NULL DEFAULT ''::character varying,
  valor_compra_anterior numeric(15,2) NOT NULL DEFAULT 0.0,
  valor_compra numeric(15,2) NOT NULL DEFAULT 0.0,
  precio_contratista_anterior numeric(15,2) NOT NULL DEFAULT 0.0,
  precio_contratista numeric(15,2) NOT NULL DEFAULT 0.0,
  observacion character varying(500) DEFAULT ''::character varying,
  precio_ultima_compra numeric(15,2) DEFAULT 0.00,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.historico_material
  OWNER TO postgres;
