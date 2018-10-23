-- Table: configuracion_pago_inicial

-- DROP TABLE configuracion_pago_inicial;

CREATE TABLE configuracion_pago_inicial
(
  id serial NOT NULL,
  tipo_negocio character varying(20) NOT NULL DEFAULT ''::character varying,
  pago_capital character varying(1) NOT NULL DEFAULT ''::character varying,
  pago_interes character varying(1) NOT NULL DEFAULT ''::character varying,
  pago_intxmora character varying(1) NOT NULL DEFAULT ''::character varying,
  pago_gac character varying(1) NOT NULL DEFAULT ''::character varying,
  pago_total character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(6) NOT NULL DEFAULT ''::character varying,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  creation_user character varying(20) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(20) DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  periodo integer NOT NULL DEFAULT 0
)
WITH (
  OIDS=FALSE
);
ALTER TABLE configuracion_pago_inicial
  OWNER TO postgres;
GRANT ALL ON TABLE configuracion_pago_inicial TO postgres;
GRANT SELECT ON TABLE configuracion_pago_inicial TO msoto;

