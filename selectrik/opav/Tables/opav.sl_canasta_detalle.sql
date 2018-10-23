-- Table: opav.sl_canasta_detalle

-- DROP TABLE opav.sl_canasta_detalle;

CREATE TABLE opav.sl_canasta_detalle
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  id_canasta integer NOT NULL DEFAULT 0,
  lote_transaccion character varying(50) NOT NULL DEFAULT ''::character varying,
  documento_origen character varying(50) NOT NULL DEFAULT ''::character varying,
  responsable character varying(100) NOT NULL DEFAULT ''::character varying,
  id_tipo_entrada integer NOT NULL DEFAULT 0,
  id_causal integer NOT NULL DEFAULT 0,
  id_tipo_movimiento integer NOT NULL DEFAULT 0,
  fecha_transaccion timestamp without time zone NOT NULL DEFAULT now(),
  tipo_insumo character varying(20) NOT NULL DEFAULT ''::character varying,
  codigo_insumo character varying(20) NOT NULL DEFAULT ''::character varying,
  descripcion_insumo text NOT NULL DEFAULT ''::character varying,
  id_unidad_medida integer NOT NULL DEFAULT 0,
  nombre_unidad_insumo character varying(20) NOT NULL DEFAULT ''::character varying,
  cantidad_afectada numeric(15,4) NOT NULL DEFAULT 0,
  costo_presupuestado numeric(15,4) NOT NULL DEFAULT 0,
  costo_unitario_compra numeric(15,4) NOT NULL DEFAULT 0,
  monto_debitado numeric(15,4) NOT NULL DEFAULT 0,
  monto_acreditado numeric(15,4) NOT NULL DEFAULT 0,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_canasta_detalle
  OWNER TO postgres;
