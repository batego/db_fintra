-- Table: opav.sl_despacho_ocs

-- DROP TABLE opav.sl_despacho_ocs;

CREATE TABLE opav.sl_despacho_ocs
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  cod_despacho character varying(20) NOT NULL DEFAULT ''::character varying,
  cod_ocs character varying(20) NOT NULL DEFAULT ''::character varying,
  cod_proveedor character varying(50) NOT NULL DEFAULT ''::character varying,
  responsable character varying(100) NOT NULL DEFAULT ''::character varying,
  direccion_entrega character varying(500) NOT NULL DEFAULT ''::character varying,
  descripcion text,
  fecha_actual timestamp without time zone NOT NULL DEFAULT now(),
  fecha_entrega timestamp without time zone NOT NULL DEFAULT (now())::date,
  forma_pago character varying(10) NOT NULL DEFAULT ''::character varying,
  estado_despacho character varying(1) NOT NULL DEFAULT '0'::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(20) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(20) NOT NULL DEFAULT ''::character varying,
  fecha_traslado_bodega timestamp without time zone,
  traslado_bodega integer NOT NULL DEFAULT 0
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_despacho_ocs
  OWNER TO postgres;
