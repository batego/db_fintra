-- Table: recaudo_eca_nuevo

-- DROP TABLE recaudo_eca_nuevo;

CREATE TABLE recaudo_eca_nuevo
(
  id serial NOT NULL,
  periodo_recaudo character varying(6) DEFAULT ''::character varying,
  fecha_vencimiento timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  nom_cli character varying(100) DEFAULT ''::character varying,
  simbolo_variable text DEFAULT ''::text,
  valor_factura numeric(18,2) DEFAULT 0,
  saldo_fac_excel moneda DEFAULT 0,
  valor_recaudo numeric(18,2) DEFAULT 0,
  cxc_excel character varying(10) DEFAULT ''::character varying,
  observacion_excel text DEFAULT ''::text,
  last_update timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) DEFAULT ''::character varying,
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(10) DEFAULT ''::character varying,
  reg_status character varying(1) DEFAULT ''::character varying,
  dstrct character varying(4) DEFAULT 'FINV'::character varying,
  saldo_recaudo numeric(18,2) DEFAULT 0,
  fecha_cruce timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  factura character varying(10) DEFAULT ''::character varying,
  procesado character varying(1) DEFAULT 'N'::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE recaudo_eca_nuevo
  OWNER TO postgres;
GRANT ALL ON TABLE recaudo_eca_nuevo TO postgres;
GRANT SELECT ON TABLE recaudo_eca_nuevo TO msoto;

