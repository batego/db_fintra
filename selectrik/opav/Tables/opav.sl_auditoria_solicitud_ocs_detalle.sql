-- Table: opav.sl_auditoria_solicitud_ocs_detalle

-- DROP TABLE opav.sl_auditoria_solicitud_ocs_detalle;

CREATE TABLE opav.sl_auditoria_solicitud_ocs_detalle
(
  id serial NOT NULL,
  id_auditoria_oc integer NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  id_solicitud_ocs integer NOT NULL,
  responsable character varying(100) NOT NULL DEFAULT ''::character varying,
  id_solicitud character varying(50) NOT NULL DEFAULT ''::character varying,
  tipo_insumo character varying(20) NOT NULL DEFAULT ''::character varying,
  codigo_insumo character varying(20) NOT NULL DEFAULT ''::character varying,
  descripcion_insumo text NOT NULL DEFAULT ''::character varying,
  referencia_externa character varying(200) NOT NULL DEFAULT ''::character varying,
  observacion_xinsumo text DEFAULT ''::character varying,
  id_unidad_medida integer NOT NULL DEFAULT 0,
  nombre_unidad_insumo character varying(20) NOT NULL DEFAULT ''::character varying,
  costo_unitario numeric(15,4) NOT NULL DEFAULT 0,
  total_pedido numeric(15,4) NOT NULL DEFAULT 0,
  insumo_adicional character varying(1) NOT NULL DEFAULT 'N'::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  total_comprado numeric(15,4) NOT NULL DEFAULT 0,
  total_saldo numeric(15,4) NOT NULL DEFAULT 0,
  estado_item character varying(1) NOT NULL DEFAULT 'N'::character varying,
  item_add character varying(1) NOT NULL DEFAULT 'N'::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_auditoria_solicitud_ocs_detalle
  OWNER TO postgres;
