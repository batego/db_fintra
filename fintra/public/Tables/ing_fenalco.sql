-- Table: ing_fenalco

-- DROP TABLE ing_fenalco;

CREATE TABLE ing_fenalco
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  cod character varying(20) NOT NULL DEFAULT ''::character varying,
  codneg character varying(10) NOT NULL DEFAULT ''::character varying,
  tipodoc character varying(10) NOT NULL DEFAULT 'IF'::character varying,
  valor moneda,
  nit character varying(15) DEFAULT ''::character varying, -- nit del cliente
  periodo character varying(6) NOT NULL DEFAULT ''::character varying,
  transaccion integer NOT NULL DEFAULT 0,
  transaccion_anulacion integer NOT NULL DEFAULT 0,
  fecha_contabilizacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  fecha_anulacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  usuario_anulacion character varying(15) NOT NULL DEFAULT ''::character varying,
  fecha_contabilizacion_anulacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  usuario_aplicacion character varying(10) NOT NULL DEFAULT ''::character varying,
  cmc character varying(30) NOT NULL DEFAULT '01'::character varying,
  fecha_doc timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  marca_reestructuracion character varying(1) NOT NULL DEFAULT 'N'::character varying,
  procesado_dif character varying NOT NULL DEFAULT 'N'::character varying,
  endosado character varying(1) NOT NULL DEFAULT 'N'::character varying,
  cuota integer NOT NULL DEFAULT 0
)
WITH (
  OIDS=FALSE
);
ALTER TABLE ing_fenalco
  OWNER TO postgres;
GRANT ALL ON TABLE ing_fenalco TO postgres;
GRANT SELECT ON TABLE ing_fenalco TO msoto;
COMMENT ON COLUMN ing_fenalco.nit IS 'nit del cliente';


