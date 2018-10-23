-- Table: con.foto_cartera

-- DROP TABLE con.foto_cartera;

CREATE TABLE con.foto_cartera
(
  id serial NOT NULL,
  periodo_lote character varying(6),
  id_convenio integer,
  creation_date timestamp without time zone DEFAULT now(),
  reg_status character varying(1),
  dstrct character varying(4),
  tipo_documento character varying(5),
  documento character varying(10) NOT NULL DEFAULT ''::character varying,
  nit character varying(15),
  codcli character varying(10),
  concepto character varying(6),
  fecha_negocio date,
  fecha_factura date,
  fecha_vencimiento date,
  fecha_ultimo_pago date,
  descripcion text,
  valor_factura moneda,
  valor_abono moneda,
  valor_saldo moneda,
  valor_facturame moneda,
  valor_abonome moneda,
  valor_saldome moneda,
  forma_pago character varying(15),
  transaccion integer,
  fecha_contabilizacion timestamp without time zone,
  creation_date_cxc timestamp without time zone DEFAULT now(),
  creation_user character varying(10),
  cmc character varying(6),
  periodo character varying(6),
  negasoc character varying(15),
  num_doc_fen character varying(20),
  agente character varying(15),
  fecha_asignacion timestamp without time zone,
  usuario_asignacion character varying(10),
  agencia_cobro character varying(6) DEFAULT ''::character varying,
  agente_campo character varying(15),
  estado_cartera character varying(10) NOT NULL DEFAULT ''::character varying,
  tramo_periodo_lote character varying(20) NOT NULL DEFAULT ''::character varying,
  tramo_anterior character varying(20) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.foto_cartera
  OWNER TO postgres;
GRANT ALL ON TABLE con.foto_cartera TO postgres;
GRANT SELECT ON TABLE con.foto_cartera TO msoto;

-- Index: con.foto_max_dias_mora

-- DROP INDEX con.foto_max_dias_mora;

CREATE INDEX foto_max_dias_mora
  ON con.foto_cartera
  USING btree
  (nit, tipo_documento, valor_saldo, negasoc, "substring"(documento::text, 1, 2));

-- Index: con.idx_foto_cartera

-- DROP INDEX con.idx_foto_cartera;

CREATE INDEX idx_foto_cartera
  ON con.foto_cartera
  USING btree
  (reg_status, dstrct, tipo_documento, negasoc, "substring"(documento::text, 1, 2), periodo_lote);

-- Index: con.idx_foto_wdocumento

-- DROP INDEX con.idx_foto_wdocumento;

CREATE INDEX idx_foto_wdocumento
  ON con.foto_cartera
  USING btree
  (documento);

-- Index: con.idx_foto_wperiodo

-- DROP INDEX con.idx_foto_wperiodo;

CREATE INDEX idx_foto_wperiodo
  ON con.foto_cartera
  USING btree
  (periodo_lote);

-- Index: con.idx_ftocartera2

-- DROP INDEX con.idx_ftocartera2;

CREATE INDEX idx_ftocartera2
  ON con.foto_cartera
  USING btree
  (periodo_lote, id_convenio, "substring"(documento::text, 1, 2));

-- Index: con.idx_ftocartera3

-- DROP INDEX con.idx_ftocartera3;

CREATE INDEX idx_ftocartera3
  ON con.foto_cartera
  USING btree
  (periodo_lote, id_convenio, documento);

-- Index: con.idx_ftocartera4

-- DROP INDEX con.idx_ftocartera4;

CREATE INDEX idx_ftocartera4
  ON con.foto_cartera
  USING btree
  (periodo_lote, negasoc, num_doc_fen, tipo_documento);

-- Index: con.idx_ftocartera5

-- DROP INDEX con.idx_ftocartera5;

CREATE INDEX idx_ftocartera5
  ON con.foto_cartera
  USING btree
  (dstrct, tipo_documento, periodo_lote, "substring"(documento::text, 1, 2));

-- Index: con.idx_ftocartera6

-- DROP INDEX con.idx_ftocartera6;

CREATE INDEX idx_ftocartera6
  ON con.foto_cartera
  USING btree
  (dstrct, tipo_documento, id_convenio, periodo_lote);

-- Index: con.idx_ftocartera_masivo

-- DROP INDEX con.idx_ftocartera_masivo;

CREATE INDEX idx_ftocartera_masivo
  ON con.foto_cartera
  USING btree
  (dstrct, reg_status, tipo_documento, periodo_lote, id_convenio, "substring"(documento::text, 1, 2));

-- Index: con.idx_ftodata

-- DROP INDEX con.idx_ftodata;

CREATE INDEX idx_ftodata
  ON con.foto_cartera
  USING btree
  (id_convenio, reg_status, dstrct, tipo_documento, agencia_cobro, periodo_lote, negasoc, nit, "substring"(documento::text, 1, 2), fecha_vencimiento);


