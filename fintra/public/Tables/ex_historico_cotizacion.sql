-- Table: ex_historico_cotizacion

-- DROP TABLE ex_historico_cotizacion;

CREATE TABLE ex_historico_cotizacion
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  idcotizacion integer NOT NULL DEFAULT 0,
  consecutivo character varying(10) NOT NULL DEFAULT ''::character varying,
  fecha timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  id_accion character varying(15) NOT NULL DEFAULT ''::character varying,
  estado character varying(1) NOT NULL DEFAULT 'P'::character varying,
  orden_generada character varying(1) NOT NULL DEFAULT 'N'::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(15) NOT NULL DEFAULT ''::character varying,
  idhistorial integer NOT NULL DEFAULT nextval('historico_cotizacion_idhistorial_seq'::regclass),
  h_creation_date timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE ex_historico_cotizacion
  OWNER TO postgres;
GRANT ALL ON TABLE ex_historico_cotizacion TO postgres;
GRANT SELECT ON TABLE ex_historico_cotizacion TO msoto;

