-- Table: tipo_de_impuesto

-- DROP TABLE tipo_de_impuesto;

CREATE TABLE tipo_de_impuesto
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'TSP'::character varying,
  codigo_impuesto character varying(6) NOT NULL DEFAULT ''::character varying,
  tipo_impuesto character varying(6) NOT NULL DEFAULT ''::character varying,
  concepto character varying(40) NOT NULL DEFAULT ''::character varying,
  descripcion text NOT NULL DEFAULT ''::text,
  fecha_vigencia date NOT NULL DEFAULT '0099-01-01'::date,
  porcentaje1 numeric(7,4) NOT NULL DEFAULT 0.0,
  porcentaje2 numeric(7,4) NOT NULL DEFAULT 0.0,
  cod_cuenta_contable character varying(20) NOT NULL DEFAULT ''::character varying,
  agencia character varying(10) NOT NULL DEFAULT 'OP'::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  ind_signo smallint NOT NULL DEFAULT 1
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tipo_de_impuesto
  OWNER TO postgres;
GRANT ALL ON TABLE tipo_de_impuesto TO postgres;
GRANT SELECT ON TABLE tipo_de_impuesto TO msoto;

