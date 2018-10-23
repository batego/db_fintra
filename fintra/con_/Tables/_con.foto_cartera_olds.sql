-- Table: con.foto_cartera_olds

-- DROP TABLE con.foto_cartera_olds;

CREATE TABLE con.foto_cartera_olds
(
  id integer,
  periodo_lote character varying(6),
  id_convenio integer,
  creation_date timestamp without time zone,
  reg_status character varying(1),
  dstrct character varying(4),
  tipo_documento character varying(5),
  documento character varying(10),
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
  creation_date_cxc timestamp without time zone,
  creation_user character varying(10),
  cmc character varying(6),
  periodo character varying(6),
  negasoc character varying(15),
  num_doc_fen character varying(20),
  agente character varying(15),
  fecha_asignacion timestamp without time zone,
  usuario_asignacion character varying(10),
  agencia_cobro character varying(6),
  agente_campo character varying(15),
  estado_cartera character varying(10),
  tramo_periodo_lote character varying(20),
  tramo_anterior character varying(20)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.foto_cartera_olds
  OWNER TO postgres;
GRANT ALL ON TABLE con.foto_cartera_olds TO postgres;
GRANT SELECT ON TABLE con.foto_cartera_olds TO msoto;

