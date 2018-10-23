-- Table: recaudo.auditoria_ingresos_automaticos

-- DROP TABLE recaudo.auditoria_ingresos_automaticos;

CREATE TABLE recaudo.auditoria_ingresos_automaticos
(
  id serial NOT NULL,
  id_recaudo integer NOT NULL,
  extracto character varying(20) NOT NULL DEFAULT ''::character varying,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  negasoc character varying(15) NOT NULL DEFAULT ''::character varying,
  periodo character varying(6) NOT NULL DEFAULT ''::character varying,
  transaccion integer,
  nit character varying(15) NOT NULL DEFAULT ''::character varying,
  codcli character varying(10) NOT NULL DEFAULT ''::character varying,
  tipo_documento character varying(5) NOT NULL DEFAULT ''::character varying,
  documento character varying(10) NOT NULL DEFAULT ''::character varying,
  num_doc_fen character varying(20) NOT NULL DEFAULT ''::character varying,
  cmc character varying(6) NOT NULL DEFAULT ''::character varying,
  fecha_vencimiento date,
  valor_factura moneda,
  valor_abono moneda,
  valor_saldo moneda,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE recaudo.auditoria_ingresos_automaticos
  OWNER TO postgres;

