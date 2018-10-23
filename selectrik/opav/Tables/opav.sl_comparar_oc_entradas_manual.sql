-- Table: opav.sl_comparar_oc_entradas_manual

-- DROP TABLE opav.sl_comparar_oc_entradas_manual;

CREATE TABLE opav.sl_comparar_oc_entradas_manual
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  cod_ocs character varying(20) NOT NULL DEFAULT ''::character varying,
  nombre_proyecto character varying(200) NOT NULL DEFAULT ''::character varying,
  num_os character varying(200) NOT NULL DEFAULT ''::character varying,
  ano character varying(200) NOT NULL DEFAULT ''::character varying,
  mes character varying(200) NOT NULL DEFAULT ''::character varying,
  dia character varying(200) NOT NULL DEFAULT ''::character varying,
  direccion_entrega character varying(200) NOT NULL DEFAULT ''::character varying,
  cod_proveedor character varying(50) NOT NULL DEFAULT ''::character varying,
  nombre_proveedor character varying(200) NOT NULL DEFAULT ''::character varying,
  codigo_insumo character varying(200) NOT NULL DEFAULT ''::character varying,
  descripcion_insumo text NOT NULL DEFAULT ''::character varying,
  cantidad_solicitada character varying(200) NOT NULL DEFAULT ''::character varying,
  costo_unitario_compra character varying(200) NOT NULL DEFAULT ''::character varying,
  costo_total_compra character varying(200) NOT NULL DEFAULT ''::character varying,
  cod_factura character varying(200) NOT NULL DEFAULT ''::character varying,
  cod_remision character varying(200) NOT NULL DEFAULT ''::character varying,
  tipo_remision character varying(200) NOT NULL DEFAULT ''::character varying,
  categoria_insumo character varying(200) NOT NULL DEFAULT ''::character varying,
  cod_movimiento character varying(200) NOT NULL DEFAULT ''::character varying,
  cantidad_movimiento character varying(200) NOT NULL DEFAULT ''::character varying,
  fecha_movimiento character varying(200) NOT NULL DEFAULT ''::character varying,
  bodega_recibe character varying(200) NOT NULL DEFAULT ''::character varying,
  origen_foms character varying(200) NOT NULL DEFAULT ''::character varying,
  origen_nombre character varying(200) NOT NULL DEFAULT ''::character varying,
  destino_foms character varying(200) NOT NULL DEFAULT ''::character varying,
  destino_nombre character varying(200) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(20) NOT NULL DEFAULT 'HCUELLO'::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(20) NOT NULL DEFAULT 'HCUELLO'::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_comparar_oc_entradas_manual
  OWNER TO postgres;
