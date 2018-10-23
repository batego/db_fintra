-- Table: dna_reliq_libranza

-- DROP TABLE dna_reliq_libranza;

CREATE TABLE dna_reliq_libranza
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
  dstrct character varying(4),
  tipo character varying(20),
  cuota_manejo moneda
)
WITH (
  OIDS=FALSE
);
ALTER TABLE dna_reliq_libranza
  OWNER TO postgres;
GRANT ALL ON TABLE dna_reliq_libranza TO postgres;
GRANT SELECT ON TABLE dna_reliq_libranza TO msoto;

