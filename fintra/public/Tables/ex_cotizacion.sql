-- Table: ex_cotizacion

-- DROP TABLE ex_cotizacion;

CREATE TABLE ex_cotizacion
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  idcotizacion integer NOT NULL DEFAULT nextval('cotizacion_idcotizacion_seq'::regclass),
  consecutivo character varying(10) NOT NULL DEFAULT ''::character varying,
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
ALTER TABLE ex_cotizacion
  OWNER TO postgres;
GRANT ALL ON TABLE ex_cotizacion TO postgres;
GRANT SELECT ON TABLE ex_cotizacion TO msoto;

-- Trigger: h_cotizacion on ex_cotizacion

-- DROP TRIGGER h_cotizacion ON ex_cotizacion;

CREATE TRIGGER h_cotizacion
  AFTER INSERT OR UPDATE
  ON ex_cotizacion
  FOR EACH ROW
  EXECUTE PROCEDURE insert_h_coti();


