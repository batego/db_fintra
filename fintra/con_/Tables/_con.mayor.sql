-- Table: con.mayor

-- DROP TABLE con.mayor;

CREATE TABLE con.mayor
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  cuenta character varying(25) NOT NULL DEFAULT ''::character varying, -- Codigo contable
  anio character varying(4) NOT NULL DEFAULT ''::character varying, -- anio de contabilizacion
  saldoant numeric(20,2) NOT NULL DEFAULT 0, -- Saldo anio anterior
  movdeb01 numeric(20,2) DEFAULT 0, -- Movimiento debito mes de enero
  movcre01 numeric(20,2) DEFAULT 0, -- Movimiento credito mes de enero
  movdeb02 numeric(20,2) DEFAULT 0, -- Movimiento debito mes de febrero
  movcre02 numeric(20,2) DEFAULT 0, -- Movimiento credito mes de febrero
  movdeb03 numeric(20,2) DEFAULT 0,
  movcre03 numeric(20,2) DEFAULT 0,
  movdeb04 numeric(20,2) DEFAULT 0,
  movcre04 numeric(20,2) DEFAULT 0,
  movdeb05 numeric(20,2) DEFAULT 0,
  movcre05 numeric(20,2) DEFAULT 0,
  movdeb06 numeric(20,2) DEFAULT 0,
  movcre06 numeric(20,2) DEFAULT 0,
  movdeb07 numeric(20,2) DEFAULT 0,
  movcre07 numeric(20,2) DEFAULT 0,
  movdeb08 numeric(20,2) DEFAULT 0,
  movcre08 numeric(20,2) DEFAULT 0,
  movdeb09 numeric(20,2) DEFAULT 0,
  movcre09 numeric(20,2) DEFAULT 0,
  movdeb10 numeric(20,2) DEFAULT 0,
  movcre10 numeric(20,2) DEFAULT 0,
  movdeb11 numeric(20,2) DEFAULT 0,
  movcre11 numeric(20,2) DEFAULT 0,
  movdeb12 numeric(20,2) DEFAULT 0,
  movcre12 numeric(20,2) DEFAULT 0,
  saldoact numeric(20,2) DEFAULT 0, -- Saldo anio actual
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  movdeb13 numeric(20,2) DEFAULT 0,
  movcre13 numeric(20,2) DEFAULT 0
)
WITH (
  OIDS=TRUE
);
ALTER TABLE con.mayor
  OWNER TO postgres;
GRANT ALL ON TABLE con.mayor TO postgres;
GRANT SELECT ON TABLE con.mayor TO msoto;
COMMENT ON TABLE con.mayor
  IS 'Tabla para mayorizacion de los comprobantes contables';
COMMENT ON COLUMN con.mayor.cuenta IS 'Codigo contable';
COMMENT ON COLUMN con.mayor.anio IS 'anio de contabilizacion';
COMMENT ON COLUMN con.mayor.saldoant IS 'Saldo anio anterior';
COMMENT ON COLUMN con.mayor.movdeb01 IS 'Movimiento debito mes de enero';
COMMENT ON COLUMN con.mayor.movcre01 IS 'Movimiento credito mes de enero';
COMMENT ON COLUMN con.mayor.movdeb02 IS 'Movimiento debito mes de febrero';
COMMENT ON COLUMN con.mayor.movcre02 IS 'Movimiento credito mes de febrero';
COMMENT ON COLUMN con.mayor.saldoact IS 'Saldo anio actual';


