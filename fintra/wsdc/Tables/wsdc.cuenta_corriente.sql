-- Table: wsdc.cuenta_corriente

-- DROP TABLE wsdc.cuenta_corriente;

CREATE TABLE wsdc.cuenta_corriente
(
  id serial NOT NULL,
  bloqueada boolean, -- true si esta bloqueada por autorregulación, posiblemente por que tiene un reclamo sin respuesta
  estado character varying,
  entidad character varying,
  ultima_actualizacion timestamp without time zone,
  numero_cuenta character varying,
  fecha_apertura timestamp without time zone,
  oficina character varying,
  ciudad character varying,
  cod_suscriptor character varying,
  situacion_titular character varying,
  tipo_identificacion smallint NOT NULL,
  identificacion character varying NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying NOT NULL,
  creation_user character varying NOT NULL,
  nit_empresa character varying NOT NULL DEFAULT '8020220161'::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT persona_cuenta_corriente_fk FOREIGN KEY (tipo_identificacion, identificacion, nit_empresa)
      REFERENCES wsdc.persona (tipo_identificacion, identificacion, nit_empresa) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE wsdc.cuenta_corriente
  OWNER TO postgres;
COMMENT ON COLUMN wsdc.cuenta_corriente.bloqueada IS 'true si esta bloqueada por autorregulación, posiblemente por que tiene un reclamo sin respuesta';


