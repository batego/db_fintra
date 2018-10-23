-- Table: con.foto_cartera_geotech

-- DROP TABLE con.foto_cartera_geotech;

CREATE TABLE con.foto_cartera_geotech
(
  id serial NOT NULL,
  periodo_lote character varying(6),
  id_convenio integer NOT NULL DEFAULT 99,
  creation_date timestamp without time zone DEFAULT now(),
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'GEOT'::character varying,
  tipo_documento character varying(5),
  documento character varying(10) NOT NULL DEFAULT ''::character varying,
  nit character varying(15),
  codcli character varying(10),
  concepto character varying(6) NOT NULL DEFAULT ''::character varying,
  fecha_negocio date,
  fecha_factura date,
  fecha_vencimiento date,
  fecha_ultimo_pago date,
  descripcion text NOT NULL DEFAULT ''::character varying,
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
ALTER TABLE con.foto_cartera_geotech
  OWNER TO postgres;
GRANT ALL ON TABLE con.foto_cartera_geotech TO postgres;

