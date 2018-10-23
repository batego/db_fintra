-- Table: recaudo.pagos_xreversar

-- DROP TABLE recaudo.pagos_xreversar;

CREATE TABLE recaudo.pagos_xreversar
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  entidadrecaudadora integer NOT NULL,
  nro_transaccion character varying(100) NOT NULL DEFAULT ''::character varying,
  cod_motivo character varying(100) NOT NULL DEFAULT ''::character varying,
  pago_reversado character varying(1) NOT NULL DEFAULT 'N'::character varying,
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(100) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(100) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE recaudo.pagos_xreversar
  OWNER TO postgres;

