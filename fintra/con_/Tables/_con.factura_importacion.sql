-- Table: con.factura_importacion

-- DROP TABLE con.factura_importacion;

CREATE TABLE con.factura_importacion
(
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying, -- Distrito de la factura
  nit character varying(15) DEFAULT ''::character varying,
  codcli character varying(10) NOT NULL DEFAULT ''::character varying,
  concepto character varying(6) NOT NULL DEFAULT ''::character varying,
  fecha_factura date DEFAULT '0099-01-01'::date,
  descripcion text NOT NULL DEFAULT ''::text,
  observacion text NOT NULL DEFAULT ''::text,
  valor_factura moneda,
  valor_tasa numeric(15,6) NOT NULL DEFAULT 0,
  moneda character varying(3) NOT NULL DEFAULT ''::character varying,
  forma_pago character varying(15) DEFAULT ''::character varying,
  plazo numeric(3,0) NOT NULL DEFAULT 0,
  formato character varying(6) DEFAULT ''::character varying,
  item character varying(30) NOT NULL DEFAULT ''::character varying,
  numero_remesa character varying(10) NOT NULL DEFAULT ''::character varying,
  fecha_remesa date DEFAULT '0099-01-01'::date,
  descripcion_item text NOT NULL DEFAULT ''::text,
  cantidad numeric(15,4) NOT NULL DEFAULT 0,
  valor_unitariome moneda,
  vlr_me moneda,
  codigo_cuenta character varying(25) NOT NULL DEFAULT ''::character varying,
  tipo_auxiliar character varying(2) NOT NULL DEFAULT ''::character varying,
  auxiliar character varying(25) NOT NULL DEFAULT ''::character varying,
  creation_user character varying(40) NOT NULL DEFAULT ''::character varying, -- Usuario de creacion de la factura
  creation_date timestamp without time zone NOT NULL DEFAULT now(), -- Fecha de Creacion de la factura
  user_update character varying(40) NOT NULL DEFAULT ''::character varying, -- Usuario de Actualizacion
  last_update timestamp without time zone NOT NULL DEFAULT now(), -- Fecha Ultima modifiacion
  fecha_migracion date NOT NULL DEFAULT '0099-01-01'::date -- fecha de Migracion a las tablas Maestras
)
WITH (
  OIDS=TRUE
);
ALTER TABLE con.factura_importacion
  OWNER TO postgres;
GRANT ALL ON TABLE con.factura_importacion TO postgres;
GRANT SELECT ON TABLE con.factura_importacion TO msoto;
COMMENT ON TABLE con.factura_importacion
  IS 'Tabla de Importacion de factura Cliente';
COMMENT ON COLUMN con.factura_importacion.dstrct IS 'Distrito de la factura';
COMMENT ON COLUMN con.factura_importacion.creation_user IS 'Usuario de creacion de la factura';
COMMENT ON COLUMN con.factura_importacion.creation_date IS 'Fecha de Creacion de la factura';
COMMENT ON COLUMN con.factura_importacion.user_update IS 'Usuario de Actualizacion';
COMMENT ON COLUMN con.factura_importacion.last_update IS 'Fecha Ultima modifiacion';
COMMENT ON COLUMN con.factura_importacion.fecha_migracion IS 'fecha de Migracion a las tablas Maestras';


