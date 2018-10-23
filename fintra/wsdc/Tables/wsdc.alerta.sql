-- Table: wsdc.alerta

-- DROP TABLE wsdc.alerta;

CREATE TABLE wsdc.alerta
(
  id serial NOT NULL,
  colocacion timestamp without time zone,
  vencimiento timestamp without time zone,
  modificacion timestamp without time zone, -- Si se especifica, el usuario cancelo la alerta explicitamente, antes de la fecha de vencimiento
  codigo character varying,
  codigo_fuente character varying, -- Codigo de la fuente
  texto character varying,
  tipo_identificacion smallint NOT NULL,
  identificacion character varying NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying NOT NULL,
  creation_user character varying NOT NULL,
  nit_empresa character varying NOT NULL DEFAULT '8020220161'::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT persona_alerta_fk FOREIGN KEY (tipo_identificacion, identificacion, nit_empresa)
      REFERENCES wsdc.persona (tipo_identificacion, identificacion, nit_empresa) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE wsdc.alerta
  OWNER TO postgres;
COMMENT ON COLUMN wsdc.alerta.modificacion IS 'Si se especifica, el usuario cancelo la alerta explicitamente, antes de la fecha de vencimiento';
COMMENT ON COLUMN wsdc.alerta.codigo_fuente IS 'Codigo de la fuente';


