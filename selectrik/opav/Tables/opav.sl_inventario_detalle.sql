-- Table: opav.sl_inventario_detalle

-- DROP TABLE opav.sl_inventario_detalle;

CREATE TABLE opav.sl_inventario_detalle
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  id_inventario integer NOT NULL,
  codigo_insumo character varying(20) NOT NULL DEFAULT ''::character varying,
  descripcion_insumo text NOT NULL DEFAULT ''::character varying,
  referencia_externa character varying(200) NOT NULL DEFAULT ''::character varying,
  observacion_xinsumo text DEFAULT ''::character varying,
  id_unidad_medida integer NOT NULL DEFAULT 0,
  nombre_unidad_insumo character varying(20) NOT NULL DEFAULT ''::character varying,
  cantidad numeric(15,4) NOT NULL DEFAULT 0,
  costo_unitario_compra numeric(15,4) NOT NULL DEFAULT 0,
  costo_total_compra numeric(15,4) NOT NULL DEFAULT 0,
  cantidad_recibida numeric(15,4) NOT NULL DEFAULT 0,
  costo_recibido numeric(15,4) NOT NULL DEFAULT 0,
  id_estado_recepcion character varying(1) NOT NULL DEFAULT 1,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_invdet_idestado FOREIGN KEY (id_estado_recepcion)
      REFERENCES opav.sl_estado_entrega (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_invdet_inventario FOREIGN KEY (id_inventario)
      REFERENCES opav.sl_inventario (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_inventario_detalle
  OWNER TO postgres;
