-- Table: wsdc.endeudamiento_global

-- DROP TABLE wsdc.endeudamiento_global;

CREATE TABLE wsdc.endeudamiento_global
(
  id serial NOT NULL,
  calificacion character varying,
  saldo_pendiente double precision, -- El dato corresponden al valor real. NO esta en miles.
  tipo_credito character varying,
  moneda character varying,
  numero_creditos integer,
  fecha_reporte timestamp without time zone,
  entidad character varying,
  garantia character varying,
  tipo_identificacion smallint NOT NULL,
  identificacion character varying NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying NOT NULL,
  creation_user character varying NOT NULL,
  nit_empresa character varying NOT NULL DEFAULT '8020220161'::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT persona_endeudamiento_global_fk FOREIGN KEY (tipo_identificacion, identificacion, nit_empresa)
      REFERENCES wsdc.persona (tipo_identificacion, identificacion, nit_empresa) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE wsdc.endeudamiento_global
  OWNER TO postgres;
COMMENT ON COLUMN wsdc.endeudamiento_global.saldo_pendiente IS 'El dato corresponden al valor real. NO esta en miles.';


