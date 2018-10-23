-- Table: opav.sl_orden_compra_servicio_prueba

-- DROP TABLE opav.sl_orden_compra_servicio_prueba;

CREATE TABLE opav.sl_orden_compra_servicio_prueba
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  cod_ocs character varying(20) NOT NULL DEFAULT ''::character varying,
  responsable character varying(100) NOT NULL DEFAULT ''::character varying,
  id_solicitud character varying(50) NOT NULL DEFAULT ''::character varying,
  cod_proveedor character varying(50) NOT NULL DEFAULT ''::character varying,
  tiposolicitud integer NOT NULL DEFAULT 0,
  bodega integer NOT NULL DEFAULT 0,
  direccion_entrega character varying(600) NOT NULL DEFAULT ''::character varying,
  descripcion text,
  fecha_actual timestamp without time zone NOT NULL DEFAULT now(),
  fecha_entrega timestamp without time zone NOT NULL DEFAULT (now())::date,
  forma_pago character varying(10) NOT NULL DEFAULT ''::character varying,
  total_insumos numeric(15,4) NOT NULL DEFAULT 0,
  estado_ocs character varying(1) NOT NULL DEFAULT '0'::character varying,
  impreso character varying(1) NOT NULL DEFAULT '0'::character varying,
  enviado_proveedor character varying(1) NOT NULL DEFAULT '0'::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(20) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(20) NOT NULL DEFAULT ''::character varying,
  observaciones text NOT NULL DEFAULT ''::text,
  pasar_apoteosys character varying(1) NOT NULL DEFAULT 'S'::character varying,
  estado_apoteosys character varying(1) NOT NULL DEFAULT 'N'::character varying,
  estado_inclusion character varying(1) DEFAULT 'S'::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_orden_compra_servicio_prueba
  OWNER TO postgres;
