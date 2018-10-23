-- Table: ex_cotizaciondets

-- DROP TABLE ex_cotizaciondets;

CREATE TABLE ex_cotizaciondets
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  idcotizaciondets integer NOT NULL DEFAULT nextval('cotizaciondets_idcotizaciondets_seq'::regclass),
  codigo_material character varying(10) NOT NULL DEFAULT ''::character varying,
  cantidad numeric(15,2) NOT NULL DEFAULT 0,
  aprobado character varying(1) NOT NULL DEFAULT ''::character varying,
  cod_cotizacion character varying(10) NOT NULL DEFAULT ''::character varying,
  fecha timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  observacion character varying(80) DEFAULT ''::character varying,
  id_accion character varying(15) DEFAULT ''::character varying,
  precio_venta moneda DEFAULT 0, -- Este es el costo contratista unitario del material mas todos los incrementos por la cantidad.
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE ex_cotizaciondets
  OWNER TO postgres;
GRANT ALL ON TABLE ex_cotizaciondets TO postgres;
GRANT SELECT ON TABLE ex_cotizaciondets TO msoto;
COMMENT ON COLUMN ex_cotizaciondets.precio_venta IS 'Este es el costo contratista unitario del material mas todos los incrementos por la cantidad. ';


-- Trigger: h_cotizaciondets on ex_cotizaciondets

-- DROP TRIGGER h_cotizaciondets ON ex_cotizaciondets;

CREATE TRIGGER h_cotizaciondets
  AFTER INSERT OR UPDATE
  ON ex_cotizaciondets
  FOR EACH ROW
  EXECUTE PROCEDURE insert_h_cotdet();


