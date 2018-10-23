-- Table: opav.sl_inventario

-- DROP TABLE opav.sl_inventario;

CREATE TABLE opav.sl_inventario
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  id_solicitud character varying(50) NOT NULL DEFAULT ''::character varying,
  id_bodega integer NOT NULL DEFAULT 0,
  id_bodega_destino integer DEFAULT 0,
  id_tipo_movimiento integer NOT NULL DEFAULT 0,
  cod_movimiento character varying(50) NOT NULL DEFAULT ''::character varying,
  cod_ocs character varying(50) NOT NULL DEFAULT ''::character varying,
  cod_despacho character varying(50) NOT NULL DEFAULT ''::character varying,
  cod_proveedor character varying(50) NOT NULL DEFAULT ''::character varying,
  responsable character varying(100) NOT NULL DEFAULT ''::character varying,
  observacion text NOT NULL DEFAULT ''::text,
  fecha_movimiento timestamp without time zone NOT NULL DEFAULT (now())::date,
  estado_plenitud character varying(1) NOT NULL DEFAULT '0'::character varying,
  estado_traslado_apoteosys character varying(1) NOT NULL DEFAULT '0'::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  id_solicitud_destino character varying,
  CONSTRAINT fk_inventario_bodega FOREIGN KEY (id_bodega)
      REFERENCES opav.sl_bodega (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_inventario_tmovimiento FOREIGN KEY (id_tipo_movimiento)
      REFERENCES opav.sl_tipo_movimiento (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_inventario
  OWNER TO postgres;
