-- Table: recaudo.entidad_recaudo

-- DROP TABLE recaudo.entidad_recaudo;

CREATE TABLE recaudo.entidad_recaudo
(
  reg_status character varying NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  codigo_entidad integer NOT NULL,
  descripcion character varying(100) NOT NULL DEFAULT ''::character varying,
  nit character varying(15) NOT NULL DEFAULT ''::character varying,
  direccion character varying(100) DEFAULT ''::character varying,
  telefono character varying(100) NOT NULL DEFAULT ''::character varying,
  email character varying(100) NOT NULL DEFAULT ''::character varying,
  ciudad character varying(6) NOT NULL DEFAULT ''::character varying,
  account_number character varying(45) NOT NULL DEFAULT ''::character varying,
  currency character varying(3) NOT NULL DEFAULT ''::character varying,
  is_bank character varying(1) DEFAULT 'N'::character varying,
  pago_automatico character varying(1) NOT NULL DEFAULT 'N'::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE recaudo.entidad_recaudo
  OWNER TO postgres;
COMMENT ON TABLE recaudo.entidad_recaudo
  IS 'Tabla donde se registran las entidades recaudadoras.';

