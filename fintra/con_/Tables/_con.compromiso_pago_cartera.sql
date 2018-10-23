-- Table: con.compromiso_pago_cartera

-- DROP TABLE con.compromiso_pago_cartera;

CREATE TABLE con.compromiso_pago_cartera
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  negocio character varying(15) NOT NULL,
  observacion text NOT NULL DEFAULT ''::character varying,
  valor_a_pagar numeric(12,2) NOT NULL,
  fecha_a_pagar date NOT NULL,
  ciudad character varying(6) NOT NULL DEFAULT ''::character varying,
  barrio character varying(160) NOT NULL DEFAULT ''::character varying,
  direccion character varying(100) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.compromiso_pago_cartera
  OWNER TO postgres;
GRANT ALL ON TABLE con.compromiso_pago_cartera TO postgres;
GRANT SELECT ON TABLE con.compromiso_pago_cartera TO msoto;

