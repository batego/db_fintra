-- Table: opav.sl_presolicitud_xapu

-- DROP TABLE opav.sl_presolicitud_xapu;

CREATE TABLE opav.sl_presolicitud_xapu
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  lote_presol character varying(20) NOT NULL DEFAULT ''::character varying,
  responsable character varying(100) NOT NULL DEFAULT ''::character varying,
  id_solicitud character varying(50) NOT NULL DEFAULT ''::character varying,
  id_apu integer NOT NULL DEFAULT 0,
  nombre_apu text NOT NULL DEFAULT ''::text,
  tipo_insumo character varying(20) NOT NULL DEFAULT ''::character varying,
  codigo_insumo character varying(20) NOT NULL DEFAULT ''::character varying,
  descripcion_insumo text NOT NULL DEFAULT ''::character varying,
  referencia_externa character varying(200) NOT NULL DEFAULT ''::character varying,
  observacion_xinsumo text DEFAULT ''::character varying,
  id_unidad_medida integer NOT NULL DEFAULT 0,
  nombre_unidad_insumo character varying(20) NOT NULL DEFAULT ''::character varying,
  costo_personalizado numeric(15,4) NOT NULL DEFAULT 0,
  insumos_total numeric(15,4) NOT NULL DEFAULT 0,
  insumos_solicitados numeric(15,4) NOT NULL DEFAULT 0,
  insumos_disponibles numeric(15,4) NOT NULL DEFAULT 0,
  solicitado_temporal numeric(15,4) NOT NULL DEFAULT 0,
  id_solicitud_ocs integer NOT NULL DEFAULT 0,
  estado_presolicitud integer NOT NULL DEFAULT 0,
  insumo_adicional character varying(1) NOT NULL DEFAULT 'N'::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_presolicitud_xapu
  OWNER TO postgres;
