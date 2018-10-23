-- Table: ex_historico_cotizaciondets

-- DROP TABLE ex_historico_cotizaciondets;

CREATE TABLE ex_historico_cotizaciondets
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  idcotizaciondets integer NOT NULL DEFAULT 0,
  codigo_material character varying(10) NOT NULL DEFAULT ''::character varying,
  cantidad integer NOT NULL DEFAULT 0,
  aprobado character varying(1) NOT NULL DEFAULT ''::character varying,
  cod_cotizacion character varying(10) NOT NULL DEFAULT ''::character varying,
  fecha timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  observacion character varying(80) DEFAULT ''::character varying,
  id_accion character varying(15) DEFAULT ''::character varying,
  precio_venta moneda DEFAULT 0,
  idhistorial_dets integer NOT NULL DEFAULT nextval('historico_cotizaciondets_idhistorial_dets_seq'::regclass),
  hdet_creation_date timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE ex_historico_cotizaciondets
  OWNER TO postgres;
GRANT ALL ON TABLE ex_historico_cotizaciondets TO postgres;
GRANT SELECT ON TABLE ex_historico_cotizaciondets TO msoto;

