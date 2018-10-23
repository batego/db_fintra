-- Table: administrativo.control_indemnizacion_fenalco

-- DROP TABLE administrativo.control_indemnizacion_fenalco;

CREATE TABLE administrativo.control_indemnizacion_fenalco
(
  id integer NOT NULL DEFAULT nextval('administrativo.control_indemnizacion_fenalco_id_seq1'::regclass),
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(6) NOT NULL DEFAULT 'FINV'::character varying,
  periodo_foto character varying(6) NOT NULL DEFAULT ''::character varying,
  codcli character varying(15) NOT NULL DEFAULT ''::character varying,
  nit_cliente character varying(20) NOT NULL DEFAULT ''::character varying,
  nombre_cliente character varying(150) NOT NULL DEFAULT ''::character varying,
  documento character varying(20) NOT NULL DEFAULT ''::character varying,
  cuota character varying(20) NOT NULL DEFAULT ''::character varying,
  valor_factura numeric(11,2) NOT NULL DEFAULT 0.00,
  valor_indemnizado numeric(11,2) NOT NULL DEFAULT 0.00,
  fecha_vencimiento timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  fecha_indemnizacion timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  negocio character varying(20) NOT NULL DEFAULT ''::character varying,
  nro_aval character varying(20) NOT NULL DEFAULT ''::character varying,
  dias_vencidos integer NOT NULL DEFAULT 0,
  id_convenio integer NOT NULL DEFAULT 0,
  cuenta_contable character varying(25) NOT NULL DEFAULT ''::character varying,
  num_comprobante character varying(30) NOT NULL DEFAULT ''::character varying,
  fecha_desistimiento timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  valor_desistido numeric(11,2) NOT NULL DEFAULT 0.00,
  ultimo_comprobante_desistimiento character varying(30) NOT NULL DEFAULT ''::character varying,
  numero_desistimientos integer NOT NULL DEFAULT 0,
  linea_negocio character varying(30) NOT NULL DEFAULT ''::character varying,
  cartera_en character varying(30) NOT NULL DEFAULT ''::character varying,
  estado_proceso character varying(2) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(15) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.control_indemnizacion_fenalco
  OWNER TO postgres;

