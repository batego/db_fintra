-- Table: control_seguros_libranza

-- DROP TABLE control_seguros_libranza;

CREATE TABLE control_seguros_libranza
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  nit character varying(15) DEFAULT ''::character varying,
  cod_neg character varying(10) NOT NULL DEFAULT ''::character varying,
  tipodoc character varying(10) NOT NULL DEFAULT 'CXP_DIF'::character varying,
  documento character varying(20) NOT NULL DEFAULT ''::character varying,
  cuota character varying(20) NOT NULL DEFAULT ''::character varying,
  fecha_vencimiento timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  valor moneda,
  periodo character varying(6) NOT NULL DEFAULT ''::character varying,
  transaccion integer NOT NULL DEFAULT 0,
  fecha_contabilizacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  usuario_aplicacion character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE control_seguros_libranza
  OWNER TO postgres;
GRANT ALL ON TABLE control_seguros_libranza TO postgres;
GRANT SELECT ON TABLE control_seguros_libranza TO msoto;

