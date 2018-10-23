-- Table: opav.sl_despacho_ocs_will_backup

-- DROP TABLE opav.sl_despacho_ocs_will_backup;

CREATE TABLE opav.sl_despacho_ocs_will_backup
(
  id integer,
  reg_status character varying(1),
  dstrct character varying(4),
  cod_despacho character varying(20),
  cod_ocs character varying(20),
  cod_proveedor character varying(50),
  responsable character varying(100),
  direccion_entrega character varying(500),
  descripcion text,
  fecha_actual timestamp without time zone,
  fecha_entrega timestamp without time zone,
  forma_pago character varying(10),
  estado_despacho character varying(1),
  creation_date timestamp without time zone,
  creation_user character varying(20),
  last_update timestamp without time zone,
  user_update character varying(20),
  fecha_traslado_bodega timestamp without time zone,
  traslado_bodega integer
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_despacho_ocs_will_backup
  OWNER TO postgres;
