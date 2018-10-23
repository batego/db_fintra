-- Table: periodos_docs_secuencias

-- DROP TABLE periodos_docs_secuencias;

CREATE TABLE periodos_docs_secuencias
(
  secuencia character varying(20) DEFAULT ''::character varying,
  tipo_operacion character varying(5) DEFAULT ''::character varying,
  periodo_os character varying(6) DEFAULT ''::character varying,
  proveedor character varying(15) DEFAULT ''::character varying,
  cxp character varying(30) DEFAULT ''::character varying,
  periodo_cxp character varying(6) DEFAULT ''::character varying,
  periodo_egreso character varying(6) DEFAULT ''::character varying,
  periodo_cxc character varying(6) DEFAULT ''::character varying,
  periodo_ing character varying(6) DEFAULT ''::character varying,
  egreso character varying(30) DEFAULT ''::character varying,
  banco character varying(15) DEFAULT ''::character varying,
  sucursal character varying(30) DEFAULT ''::character varying,
  num serial NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE periodos_docs_secuencias
  OWNER TO postgres;
GRANT ALL ON TABLE periodos_docs_secuencias TO postgres;
GRANT SELECT ON TABLE periodos_docs_secuencias TO msoto;

