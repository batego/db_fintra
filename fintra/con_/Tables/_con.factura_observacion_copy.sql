-- Table: con.factura_observacion_copy

-- DROP TABLE con.factura_observacion_copy;

CREATE TABLE con.factura_observacion_copy
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(15) NOT NULL DEFAULT ''::character varying,
  documento character varying(30) NOT NULL DEFAULT ''::character varying,
  observacion text NOT NULL DEFAULT ''::text,
  last_update timestamp without time zone NOT NULL DEFAULT (now())::timestamp without time zone,
  user_update character varying NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT (now())::timestamp without time zone,
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  base character varying(3) DEFAULT ''::character varying,
  id integer NOT NULL DEFAULT nextval('con.factura_observacion_id_seq'::regclass),
  tipo_gestion text NOT NULL DEFAULT '0'::text, -- codigo en tablagen del tipo de gestion. table_type=TIPOGEST
  fecha_prox_gestion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- fecha de la proxima gestion
  prox_accion text NOT NULL DEFAULT '0'::text, -- codigo de la proxima accion en tablagen
  tipo character varying(6) NOT NULL DEFAULT ''::character varying,
  dato character varying(60) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE con.factura_observacion_copy
  OWNER TO postgres;
GRANT ALL ON TABLE con.factura_observacion_copy TO postgres;
GRANT SELECT ON TABLE con.factura_observacion_copy TO msoto;
COMMENT ON COLUMN con.factura_observacion_copy.tipo_gestion IS 'codigo en tablagen del tipo de gestion. table_type=TIPOGEST';
COMMENT ON COLUMN con.factura_observacion_copy.fecha_prox_gestion IS 'fecha de la proxima gestion';
COMMENT ON COLUMN con.factura_observacion_copy.prox_accion IS 'codigo de la proxima accion en tablagen';


