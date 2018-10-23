-- Table: business_intelligence.eg_movimiento_tsp_paso_aga

-- DROP TABLE business_intelligence.eg_movimiento_tsp_paso_aga;

CREATE TABLE business_intelligence.eg_movimiento_tsp_paso_aga
(
  id serial NOT NULL,
  dstrct character varying,
  cuenta character varying,
  auxiliar character varying,
  periodo character varying,
  fechadoc character varying,
  tipodoc character varying,
  tipodoc_desc text,
  numdoc character varying,
  detalle character varying,
  detalle_comprobante character varying,
  abc character varying,
  valor_debito numeric,
  valor_credito numeric,
  tercero character varying,
  nombre_tercero text,
  tipodoc_rel character varying,
  documento_rel character varying,
  vlr_for numeric,
  modena_foranea character varying,
  tipo_referencia_1 character varying,
  referencia_1 character varying,
  tipo_referencia_2 character varying,
  referencia_2 character varying,
  tipo_referencia_3 character varying,
  referencia_3 character varying,
  documento_rel2 character varying,
  referencia_4 character varying,
  tipo_convenio character varying,
  clasificacion character varying,
  paso character varying,
  fk_repo_prod integer
)
WITH (
  OIDS=FALSE
);
ALTER TABLE business_intelligence.eg_movimiento_tsp_paso_aga
  OWNER TO postgres;

