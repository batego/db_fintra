-- Table: opav.sl_solicitud_ejecucion

-- DROP TABLE opav.sl_solicitud_ejecucion;

CREATE TABLE opav.sl_solicitud_ejecucion
(
  id serial NOT NULL,
  id_solicitud character varying(50),
  id_bodega_ejecucion integer NOT NULL DEFAULT 0,
  id_bodega_proyecto integer NOT NULL DEFAULT 0,
  cod_solicitud character varying NOT NULL DEFAULT 0,
  fecha_esperada_entrega character varying,
  fecha_real_entrega character varying,
  observaciones character varying,
  id_estado_solicitud_ejecucion character varying NOT NULL DEFAULT 0,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_solicitud_ejecucion
  OWNER TO postgres;
