-- Table: con.foto_ciclo_pagos

-- DROP TABLE con.foto_ciclo_pagos;

CREATE TABLE con.foto_ciclo_pagos
(
  id serial NOT NULL,
  reg_status character varying(1),
  dstrct character varying(4),
  periodo_lote character varying(6),
  id_ciclo integer,
  periodo character varying(6),
  negasoc character varying(15),
  nit character varying(15),
  codcli character varying(10),
  num_doc_fen character varying(20),
  id_convenio integer,
  tipo_documento character varying(5),
  documento character varying(10) NOT NULL DEFAULT ''::character varying,
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
  cmc character varying(6),
  agente character varying(15),
  fecha_asignacion timestamp without time zone,
  usuario_asignacion character varying(15),
  agencia_cobro character varying(6) DEFAULT ''::character varying,
  agente_campo character varying(15),
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(15),
  CONSTRAINT foto_ciclo_pagos_id_ciclo_fkey FOREIGN KEY (id_ciclo)
      REFERENCES con.ciclos_facturacion (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.foto_ciclo_pagos
  OWNER TO postgres;
GRANT ALL ON TABLE con.foto_ciclo_pagos TO postgres;
GRANT SELECT ON TABLE con.foto_ciclo_pagos TO msoto;

