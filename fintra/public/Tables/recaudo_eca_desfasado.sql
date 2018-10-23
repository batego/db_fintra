-- Table: recaudo_eca_desfasado

-- DROP TABLE recaudo_eca_desfasado;

CREATE TABLE recaudo_eca_desfasado
(
  documento_cxc character varying(10) DEFAULT ''::character varying,
  tipo_documento_cxc character varying(5) NOT NULL DEFAULT ''::character varying,
  fecha_vencimiento_cxc date DEFAULT '0099-01-01'::date,
  valor_cxc moneda,
  saldo_cxc_antes moneda,
  ms_cxc character varying(15) DEFAULT ''::character varying,
  pk_recaudo integer,
  fecha_recaudo timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  valor_recaudo numeric(18,2) DEFAULT 0,
  saldo_recaudo_antes numeric(18,2) DEFAULT 0,
  ms_recaudo character varying(15) DEFAULT ''::character varying,
  creation_date timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id serial NOT NULL,
  procesado character varying(2) NOT NULL DEFAULT 'NO'::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE recaudo_eca_desfasado
  OWNER TO postgres;
GRANT ALL ON TABLE recaudo_eca_desfasado TO postgres;
GRANT SELECT ON TABLE recaudo_eca_desfasado TO msoto;

