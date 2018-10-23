-- Table: opav.sl_auditoria_ocs_borradas

-- DROP TABLE opav.sl_auditoria_ocs_borradas;

CREATE TABLE opav.sl_auditoria_ocs_borradas
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  cod_ocs character varying(20) NOT NULL DEFAULT ''::character varying,
  responsable character varying(100) NOT NULL DEFAULT ''::character varying,
  cod_proveedor character varying(50) NOT NULL DEFAULT ''::character varying,
  tiposolicitud integer NOT NULL DEFAULT 0,
  bodega integer NOT NULL DEFAULT 0,
  direccion_entrega character varying(300) NOT NULL DEFAULT ''::character varying,
  descripcion text,
  fecha_actual timestamp without time zone NOT NULL DEFAULT now(),
  fecha_entrega timestamp without time zone NOT NULL DEFAULT (now())::date,
  forma_pago character varying(10) NOT NULL DEFAULT ''::character varying,
  lote_ocs character varying(20) NOT NULL DEFAULT ''::character varying,
  cod_solicitud character varying(50) NOT NULL DEFAULT ''::character varying,
  codigo_insumo character varying(20) NOT NULL DEFAULT ''::character varying,
  descripcion_insumo text NOT NULL DEFAULT ''::character varying,
  referencia_externa character varying(200) NOT NULL DEFAULT ''::character varying,
  observacion_xinsumo text DEFAULT ''::character varying,
  id_unidad_medida integer NOT NULL DEFAULT 0,
  nombre_unidad_insumo character varying(20) NOT NULL DEFAULT ''::character varying,
  cantidad_solicitada numeric(15,4) NOT NULL DEFAULT 0,
  costo_unitario_compra numeric(15,4) NOT NULL DEFAULT 0,
  costo_total_compra numeric(15,4) NOT NULL DEFAULT 0,
  insumo_adicional character varying(1) NOT NULL DEFAULT 'N'::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_auditoria_ocs_borradas
  OWNER TO postgres;
