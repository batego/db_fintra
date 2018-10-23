-- Table: con.factura_detalle_prueba

-- DROP TABLE con.factura_detalle_prueba;

CREATE TABLE con.factura_detalle_prueba
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  tipo_documento character varying(5) NOT NULL DEFAULT ''::character varying,
  documento character varying(10) NOT NULL DEFAULT ''::character varying,
  item numeric(4,0) NOT NULL DEFAULT 0,
  nit character varying(15) DEFAULT ''::character varying,
  concepto character varying(6) NOT NULL DEFAULT ''::character varying,
  numero_remesa character varying(10) NOT NULL DEFAULT ''::character varying,
  descripcion text NOT NULL DEFAULT ''::text,
  codigo_cuenta_contable character varying(30) NOT NULL DEFAULT ''::character varying,
  cantidad numeric(15,4) NOT NULL DEFAULT 0,
  valor_unitario moneda,
  valor_unitariome moneda,
  valor_item moneda,
  valor_itemme moneda,
  valor_tasa numeric(15,6) NOT NULL DEFAULT 0,
  moneda character varying(3) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  auxiliar character varying(18) DEFAULT ''::character varying,
  valor_ingreso moneda,
  tipo_documento_rel character varying(15) NOT NULL DEFAULT ''::character varying,
  transaccion integer NOT NULL DEFAULT 0,
  documento_relacionado text NOT NULL DEFAULT ''::text,
  tipo_referencia_1 character varying(5) NOT NULL DEFAULT ''::character varying,
  referencia_1 character varying(30) NOT NULL DEFAULT ''::character varying,
  tipo_referencia_2 character varying(5) NOT NULL DEFAULT ''::character varying,
  referencia_2 character varying(30) NOT NULL DEFAULT ''::character varying,
  tipo_referencia_3 character varying(5) NOT NULL DEFAULT ''::character varying,
  referencia_3 character varying(30) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE con.factura_detalle_prueba
  OWNER TO postgres;
GRANT ALL ON TABLE con.factura_detalle_prueba TO postgres;
GRANT SELECT ON TABLE con.factura_detalle_prueba TO msoto;

