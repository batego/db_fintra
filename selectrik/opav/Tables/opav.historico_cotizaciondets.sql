-- Table: opav.historico_cotizaciondets

-- DROP TABLE opav.historico_cotizaciondets;

CREATE TABLE opav.historico_cotizaciondets
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  idcotizaciondets integer NOT NULL DEFAULT 0,
  codigo_material character varying(10) NOT NULL DEFAULT ''::character varying,
  cantidad integer NOT NULL DEFAULT 0,
  aprobado character varying(1) NOT NULL DEFAULT ''::character varying,
  cod_cotizacion character varying(13) NOT NULL DEFAULT ''::character varying,
  fecha timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  observacion character varying(80) DEFAULT ''::character varying,
  id_accion character varying(15) DEFAULT ''::character varying,
  precio_venta moneda DEFAULT 0,
  idhistorial_dets serial NOT NULL,
  hdet_creation_date timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying, -- Usuario que realizo la creacion del registro
  creation_date timestamp with time zone NOT NULL DEFAULT now(), -- Fecha de creacion del registro
  user_update character varying(10) NOT NULL DEFAULT ''::character varying, -- Usuario que realizo la ultima actualizacion del registro
  last_update time without time zone NOT NULL DEFAULT '00:00:00'::time without time zone, -- Fecha ultima actualizacion del registro
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.historico_cotizaciondets
  OWNER TO postgres;
COMMENT ON COLUMN opav.historico_cotizaciondets.creation_user IS 'Usuario que realizo la creacion del registro';
COMMENT ON COLUMN opav.historico_cotizaciondets.creation_date IS 'Fecha de creacion del registro';
COMMENT ON COLUMN opav.historico_cotizaciondets.user_update IS 'Usuario que realizo la ultima actualizacion del registro';
COMMENT ON COLUMN opav.historico_cotizaciondets.last_update IS 'Fecha ultima actualizacion del registro';
