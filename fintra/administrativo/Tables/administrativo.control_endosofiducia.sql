-- Table: administrativo.control_endosofiducia

-- DROP TABLE administrativo.control_endosofiducia;

CREATE TABLE administrativo.control_endosofiducia
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(6) NOT NULL DEFAULT 'FINV'::character varying,
  lote_endoso integer NOT NULL DEFAULT 0,
  endosar_en character varying(60) NOT NULL DEFAULT ''::character varying,
  anteriormente_en character varying(60) NOT NULL DEFAULT ''::character varying,
  fecha_corte timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  fecha_endoso timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  linea_negocio character varying(30) NOT NULL DEFAULT ''::character varying,
  id_unidad_negocio integer NOT NULL DEFAULT 0,
  unidad_negocio character varying(30) NOT NULL DEFAULT ''::character varying,
  nit_cliente character varying(20) NOT NULL DEFAULT ''::character varying,
  nombre_cliente character varying(150) NOT NULL DEFAULT ''::character varying,
  codcli character varying(15) NOT NULL DEFAULT ''::character varying,
  negocio character varying(20) NOT NULL DEFAULT ''::character varying,
  tipo_negocio character varying(150) NOT NULL DEFAULT ''::character varying,
  documento character varying(20) NOT NULL DEFAULT ''::character varying,
  cuota character varying(20) NOT NULL DEFAULT ''::character varying,
  fecha_vencimiento timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  dias_vencidos integer NOT NULL DEFAULT 0,
  valor_factura_trasladado numeric(11,2) NOT NULL DEFAULT 0.00,
  valor_abono_trasladado numeric(11,2) NOT NULL DEFAULT 0.00,
  valor_saldo_trasladado numeric(11,2) NOT NULL DEFAULT 0.00,
  num_comprobante character varying(30) NOT NULL DEFAULT ''::character varying,
  fecha_cdiar timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  estado_proceso character varying(30) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(15) NOT NULL DEFAULT ''::character varying,
  procesado_en character varying(1) NOT NULL DEFAULT 'N'::character varying,
  num_comprobante_reconstruido character varying(30) DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.control_endosofiducia
  OWNER TO postgres;

