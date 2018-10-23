-- Table: fin.plan_pago_creditos_bancarios

-- DROP TABLE fin.plan_pago_creditos_bancarios;

CREATE TABLE fin.plan_pago_creditos_bancarios
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  documento character varying(100) NOT NULL DEFAULT ''::character varying,
  nit_banco character varying(15) NOT NULL DEFAULT ''::character varying,
  fecha_inicial timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  fecha_vencimiento timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  valor_cuota numeric(11,2) NOT NULL DEFAULT 0.00,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(50) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(50) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fin.plan_pago_creditos_bancarios
  OWNER TO postgres;

