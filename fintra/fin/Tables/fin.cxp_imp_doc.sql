-- Table: fin.cxp_imp_doc

-- DROP TABLE fin.cxp_imp_doc;

CREATE TABLE fin.cxp_imp_doc
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(15) NOT NULL DEFAULT ''::character varying,
  proveedor character varying(15) NOT NULL DEFAULT ''::character varying,
  tipo_documento character varying(15) NOT NULL DEFAULT ''::character varying,
  documento character varying(30) NOT NULL DEFAULT ''::character varying,
  cod_impuesto character varying(15) NOT NULL DEFAULT ''::character varying,
  porcent_impuesto numeric(5,2) NOT NULL DEFAULT 0,
  vlr_total_impuesto moneda,
  vlr_total_impuesto_me moneda,
  last_update timestamp without time zone NOT NULL DEFAULT (now())::timestamp without time zone,
  user_update character varying NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT (now())::timestamp without time zone,
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  base character varying(3) DEFAULT ''::character varying,
  proveedor_rel character varying(15) NOT NULL DEFAULT ''::character varying,
  item character varying(30) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT cxp_imp_doc FOREIGN KEY (dstrct, proveedor, tipo_documento, documento)
      REFERENCES fin.cxp_doc (dstrct, proveedor, tipo_documento, documento) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE
)
WITH (
  OIDS=TRUE
);
ALTER TABLE fin.cxp_imp_doc
  OWNER TO postgres;
COMMENT ON TABLE fin.cxp_imp_doc
  IS 'Registra los impuestos del Documento';

