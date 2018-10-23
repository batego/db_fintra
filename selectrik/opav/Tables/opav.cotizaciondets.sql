-- Table: opav.cotizaciondets

-- DROP TABLE opav.cotizaciondets;

CREATE TABLE opav.cotizaciondets
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  idcotizaciondets serial NOT NULL,
  codigo_material character varying(10) NOT NULL DEFAULT ''::character varying,
  cantidad numeric(15,5) NOT NULL DEFAULT 0,
  aprobado character varying(1) NOT NULL DEFAULT ''::character varying,
  cod_cotizacion character varying(13) NOT NULL DEFAULT ''::character varying,
  fecha timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  observacion character varying(80) DEFAULT ''::character varying,
  id_accion character varying(15) DEFAULT ''::character varying,
  precio_venta moneda DEFAULT 0, -- Este es el costo contratista unitario del material mas todos los incrementos por la cantidad.
  compra_provint character varying(1) DEFAULT 'S'::character varying,
  cant_provint numeric DEFAULT 0,
  precio numeric(15,2) NOT NULL DEFAULT 0,
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying, -- Usuario que realizo la creacion del registro
  creation_date timestamp with time zone NOT NULL DEFAULT now(), -- Fecha de creacion del registro
  user_update character varying(10) NOT NULL DEFAULT ''::character varying, -- Usuario que realizo la ultima actualizacion del registro
  last_update time without time zone NOT NULL DEFAULT '00:00:00'::time without time zone, -- Fecha ultima actualizacion del registro
  cant_comprada numeric DEFAULT 0,
  oficial character varying(4),
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.cotizaciondets
  OWNER TO postgres;
COMMENT ON COLUMN opav.cotizaciondets.precio_venta IS 'Este es el costo contratista unitario del material mas todos los incrementos por la cantidad. ';
COMMENT ON COLUMN opav.cotizaciondets.creation_user IS 'Usuario que realizo la creacion del registro';
COMMENT ON COLUMN opav.cotizaciondets.creation_date IS 'Fecha de creacion del registro';
COMMENT ON COLUMN opav.cotizaciondets.user_update IS 'Usuario que realizo la ultima actualizacion del registro';
COMMENT ON COLUMN opav.cotizaciondets.last_update IS 'Fecha ultima actualizacion del registro';


-- Trigger: h_cotizaciondets on opav.cotizaciondets

-- DROP TRIGGER h_cotizaciondets ON opav.cotizaciondets;

CREATE TRIGGER h_cotizaciondets
  AFTER INSERT OR UPDATE
  ON opav.cotizaciondets
  FOR EACH ROW
  EXECUTE PROCEDURE insert_h_cotdet();
