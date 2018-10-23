-- Table: opav.sl_comparar_oc_entradas_manual_fiel_will_salvado_v1

-- DROP TABLE opav.sl_comparar_oc_entradas_manual_fiel_will_salvado_v1;

CREATE TABLE opav.sl_comparar_oc_entradas_manual_fiel_will_salvado_v1
(
  id integer,
  reg_status character varying(1),
  dstrct character varying(4),
  cod_ocs character varying(20),
  nombre_proyecto character varying(200),
  num_os character varying(200),
  ano character varying(200),
  mes character varying(200),
  dia character varying(200),
  direccion_entrega character varying(200),
  cod_proveedor character varying(50),
  nombre_proveedor character varying(200),
  codigo_insumo character varying(200),
  descripcion_insumo text,
  cantidad_solicitada character varying(200),
  costo_unitario_compra character varying(200),
  costo_total_compra character varying(200),
  cod_factura character varying(200),
  cod_remision character varying(200),
  tipo_remision character varying(200),
  categoria_insumo character varying(200),
  cod_movimiento character varying(200),
  cantidad_movimiento character varying(200),
  fecha_movimiento character varying(200),
  bodega_recibe character varying(200),
  origen_foms character varying(200),
  origen_nombre character varying(200),
  destino_foms character varying(200),
  destino_nombre character varying(200),
  valor_total_christina character varying(30),
  creation_date timestamp without time zone,
  creation_user character varying(20),
  last_update timestamp without time zone,
  user_update character varying(20)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_comparar_oc_entradas_manual_fiel_will_salvado_v1
  OWNER TO postgres;
