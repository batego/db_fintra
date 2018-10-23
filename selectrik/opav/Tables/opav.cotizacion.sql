-- Table: opav.cotizacion

-- DROP TABLE opav.cotizacion;

CREATE TABLE opav.cotizacion
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  idcotizacion integer NOT NULL,
  consecutivo character varying(13) NOT NULL DEFAULT ''::character varying,
  fecha timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  id_accion character varying(15) NOT NULL DEFAULT ''::character varying,
  estado character varying(1) NOT NULL DEFAULT 'P'::character varying,
  orden_generada character varying(1) NOT NULL DEFAULT 'N'::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(15) NOT NULL DEFAULT 'ADMIN'::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.cotizacion
  OWNER TO postgres;

-- Trigger: h_cotizacion on opav.cotizacion

-- DROP TRIGGER h_cotizacion ON opav.cotizacion;

CREATE TRIGGER h_cotizacion
  AFTER INSERT OR UPDATE
  ON opav.cotizacion
  FOR EACH ROW
  EXECUTE PROCEDURE insert_h_coti();
