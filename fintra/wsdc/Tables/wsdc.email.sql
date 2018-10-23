-- Table: wsdc.email

-- DROP TABLE wsdc.email;

CREATE TABLE wsdc.email
(
  id integer NOT NULL DEFAULT nextval('wsdc.email_secuencia_seq'::regclass),
  direccion character varying,
  tipo character varying, -- M - Móvil, R - Residencia, L - Laboral, C - Correspondencia
  creacion timestamp without time zone,
  actualizacion timestamp without time zone,
  num_reportes integer,
  fuente character varying,
  reportado character varying,
  entidad character varying,
  tipo_identificacion smallint NOT NULL,
  identificacion character varying NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying NOT NULL,
  creation_user character varying NOT NULL,
  nit_empresa character varying NOT NULL DEFAULT '8020220161'::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT entidad_email_fk FOREIGN KEY (entidad)
      REFERENCES wsdc.entidad (codigo_suscriptor) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT persona_email_fk FOREIGN KEY (tipo_identificacion, identificacion, nit_empresa)
      REFERENCES wsdc.persona (tipo_identificacion, identificacion, nit_empresa) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE wsdc.email
  OWNER TO postgres;
COMMENT ON COLUMN wsdc.email.tipo IS 'M - Móvil, R - Residencia, L - Laboral, C - Correspondencia';


