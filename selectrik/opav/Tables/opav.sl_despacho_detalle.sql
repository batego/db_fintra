-- Table: opav.sl_despacho_detalle

-- DROP TABLE opav.sl_despacho_detalle;

CREATE TABLE opav.sl_despacho_detalle
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  id_despacho integer NOT NULL,
  id_ocs_detalle integer NOT NULL,
  responsable character varying(100) NOT NULL DEFAULT ''::character varying,
  codigo_insumo character varying(20) NOT NULL DEFAULT ''::character varying,
  descripcion_insumo text NOT NULL DEFAULT ''::character varying,
  referencia_externa character varying(200) NOT NULL DEFAULT ''::character varying,
  id_unidad_medida integer NOT NULL DEFAULT 0,
  nombre_unidad_insumo character varying(20) NOT NULL DEFAULT ''::character varying,
  cantidad_recibida numeric(15,4) NOT NULL DEFAULT 0,
  costo_unitario_recibido numeric(15,4) NOT NULL DEFAULT 0,
  costo_total_recibido numeric(15,4) NOT NULL DEFAULT 0,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(20) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(20) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_despacho FOREIGN KEY (id_despacho)
      REFERENCES opav.sl_despacho_ocs (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_despacho_detalle
  OWNER TO postgres;
