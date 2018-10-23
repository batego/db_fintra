-- Table: con.mayorharold20150520

-- DROP TABLE con.mayorharold20150520;

CREATE TABLE con.mayorharold20150520
(
  reg_status character varying(1),
  dstrct character varying(4),
  cuenta character varying(25),
  anio character varying(4),
  saldoant numeric(20,2),
  movdeb01 numeric(20,2),
  movcre01 numeric(20,2),
  movdeb02 numeric(20,2),
  movcre02 numeric(20,2),
  movdeb03 numeric(20,2),
  movcre03 numeric(20,2),
  movdeb04 numeric(20,2),
  movcre04 numeric(20,2),
  movdeb05 numeric(20,2),
  movcre05 numeric(20,2),
  movdeb06 numeric(20,2),
  movcre06 numeric(20,2),
  movdeb07 numeric(20,2),
  movcre07 numeric(20,2),
  movdeb08 numeric(20,2),
  movcre08 numeric(20,2),
  movdeb09 numeric(20,2),
  movcre09 numeric(20,2),
  movdeb10 numeric(20,2),
  movcre10 numeric(20,2),
  movdeb11 numeric(20,2),
  movcre11 numeric(20,2),
  movdeb12 numeric(20,2),
  movcre12 numeric(20,2),
  saldoact numeric(20,2),
  last_update timestamp without time zone,
  user_update character varying(10),
  creation_date timestamp without time zone,
  creation_user character varying(10),
  base character varying(3),
  movdeb13 numeric(20,2),
  movcre13 numeric(20,2)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.mayorharold20150520
  OWNER TO postgres;
GRANT ALL ON TABLE con.mayorharold20150520 TO postgres;
GRANT SELECT ON TABLE con.mayorharold20150520 TO msoto;

