-- Table: configuracion_transferencias

-- DROP TABLE configuracion_transferencias;

CREATE TABLE configuracion_transferencias
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT 'FINV'::character varying,
  nit character varying(15) NOT NULL DEFAULT ''::character varying,
  numero_cuenta character varying(15) NOT NULL DEFAULT ''::character varying,
  tipo_cuenta character varying(15) NOT NULL DEFAULT ''::character varying,
  tipo_operacion_cliente character varying(15) NOT NULL DEFAULT ''::character varying,
  tipo_transaccion_proveedor character varying(15) NOT NULL DEFAULT ''::character varying,
  secuencia_nota_adicional character varying(15) NOT NULL DEFAULT ''::character varying,
  observacion character varying(30) NOT NULL DEFAULT ''::character varying,
  nombre character varying(15) NOT NULL DEFAULT ''::character varying,
  head character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE configuracion_transferencias
  OWNER TO postgres;
GRANT ALL ON TABLE configuracion_transferencias TO postgres;
GRANT SELECT ON TABLE configuracion_transferencias TO msoto;

