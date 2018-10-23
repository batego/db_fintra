-- Table: opav.sl_auditoria_solicitud_ocs

-- DROP TABLE opav.sl_auditoria_solicitud_ocs;

CREATE TABLE opav.sl_auditoria_solicitud_ocs
(
  id serial NOT NULL,
  id_auditoria_oc integer NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  cod_solicitud character varying(20) NOT NULL DEFAULT ''::character varying,
  responsable character varying(100) NOT NULL DEFAULT ''::character varying,
  id_solicitud character varying(50) NOT NULL DEFAULT ''::character varying,
  tiposolicitud integer NOT NULL DEFAULT 0,
  bodega integer NOT NULL DEFAULT 0,
  descripcion text,
  fecha_actual timestamp without time zone NOT NULL DEFAULT now(),
  fecha_entrega timestamp without time zone NOT NULL DEFAULT (now())::date,
  total_insumos numeric(15,4) NOT NULL DEFAULT 0,
  estado_presolicitud character varying(1) NOT NULL DEFAULT '0'::character varying,
  estado_solicitud character varying(1) NOT NULL DEFAULT '0'::character varying,
  aprobar_solicitud character varying(1) NOT NULL DEFAULT ''::character varying,
  usuario_aprobacion character varying(50) NOT NULL DEFAULT ''::character varying,
  razones text NOT NULL DEFAULT ''::text,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  sol_add character varying(1) NOT NULL DEFAULT 'N'::character varying,
  cot_tercerizada character varying(15) DEFAULT ''::character varying,
  direccion_entrega character varying(300) NOT NULL DEFAULT ''::character varying,
  id_bodega integer
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_auditoria_solicitud_ocs
  OWNER TO postgres;
