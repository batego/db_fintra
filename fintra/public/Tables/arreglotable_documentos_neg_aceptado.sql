-- Table: arreglotable_documentos_neg_aceptado

-- DROP TABLE arreglotable_documentos_neg_aceptado;

CREATE TABLE arreglotable_documentos_neg_aceptado
(
  cod_neg character varying(15),
  item character varying(15),
  fecha timestamp without time zone,
  dias numeric(5,0),
  saldo_inicial moneda,
  capital moneda,
  interes moneda,
  valor moneda,
  saldo_final moneda,
  reg_status character varying(1),
  creation_date timestamp without time zone,
  no_aval moneda,
  capacitacion moneda,
  cat moneda,
  seguro moneda,
  interes_causado moneda,
  fch_interes_causado timestamp without time zone,
  documento_cat character varying(10),
  custodia numeric(10,2),
  remesa numeric(10,2),
  causar character varying(1),
  negasoc character varying(15),
  documento character varying(10),
  num_doc_fen character varying(20),
  "?column?" moneda,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE arreglotable_documentos_neg_aceptado
  OWNER TO postgres;
GRANT ALL ON TABLE arreglotable_documentos_neg_aceptado TO postgres;
GRANT SELECT ON TABLE arreglotable_documentos_neg_aceptado TO msoto;

