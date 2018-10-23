-- Table: opav.sl_162

-- DROP TABLE opav.sl_162;

CREATE TABLE opav.sl_162
(
  id integer,
  reg_status character varying(1),
  dstrct character varying(4),
  cod_ocs character varying(20),
  responsable character varying(100),
  id_solicitud character varying(50),
  cod_proveedor character varying(50),
  tiposolicitud integer,
  bodega integer,
  direccion_entrega character varying(600),
  descripcion text,
  fecha_actual timestamp without time zone,
  fecha_entrega timestamp without time zone,
  forma_pago character varying(10),
  total_insumos numeric(15,4),
  estado_ocs character varying(1),
  impreso character varying(1),
  enviado_proveedor character varying(1),
  creation_date timestamp without time zone,
  creation_user character varying(20),
  last_update timestamp without time zone,
  user_update character varying(20),
  observaciones text,
  pasar_apoteosys character varying(1),
  estado_apoteosys character varying(1),
  estado_inclusion character varying(1),
  no_despacho character varying(20)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_162
  OWNER TO postgres;
