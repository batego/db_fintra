-- Table: con.saldos_bancos_colocacion

-- DROP TABLE con.saldos_bancos_colocacion;

CREATE TABLE con.saldos_bancos_colocacion
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT 'FINV'::character varying,
  cuenta character varying(20) NOT NULL DEFAULT ''::character varying,
  nombre_cuenta character varying(150) NOT NULL DEFAULT ''::character varying,
  saldo_anterior numeric NOT NULL DEFAULT 0,
  vlr_debito numeric NOT NULL DEFAULT 0,
  vlr_credito numeric NOT NULL DEFAULT 0,
  saldo_actual numeric NOT NULL DEFAULT 0,
  saldo_extracto numeric NOT NULL DEFAULT 0,
  diferencia numeric NOT NULL DEFAULT 0,
  fecha_movimiento timestamp without time zone DEFAULT now(),
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.saldos_bancos_colocacion
  OWNER TO postgres;
GRANT ALL ON TABLE con.saldos_bancos_colocacion TO postgres;
GRANT SELECT ON TABLE con.saldos_bancos_colocacion TO msoto;

