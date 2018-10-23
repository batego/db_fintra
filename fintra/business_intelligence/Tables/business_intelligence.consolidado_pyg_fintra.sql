-- Table: business_intelligence.consolidado_pyg_fintra

-- DROP TABLE business_intelligence.consolidado_pyg_fintra;

CREATE TABLE business_intelligence.consolidado_pyg_fintra
(
  id serial NOT NULL,
  anio text,
  periodo character varying(6),
  tipo text,
  cuenta character varying(25),
  centro_costo text,
  nombre_cuenta character varying(150),
  tercero character varying(15),
  nombre_tercero text,
  tipodoc character varying(5),
  numdoc character varying(30),
  detalle text,
  tipodoc_rel character varying(5),
  documento_rel character varying(30),
  valor_debito numeric,
  valor_credito numeric,
  diferencia numeric
)
WITH (
  OIDS=FALSE
);
ALTER TABLE business_intelligence.consolidado_pyg_fintra
  OWNER TO postgres;

