-- Table: wsdc.direccion

-- DROP TABLE wsdc.direccion;

CREATE TABLE wsdc.direccion
(
  id integer NOT NULL DEFAULT nextval('wsdc.direccion_secuencia_seq'::regclass),
  tipo character varying, -- M - Móvil, R - Residencia, L - Laboral
  direccion character varying,
  fuente character varying,
  creacion timestamp without time zone,
  actualizacion timestamp without time zone,
  num_reportes integer,
  estrato character varying,
  probabilidad_entrega character varying,
  ciudad character varying,
  departamento character varying,
  pais character varying,
  nueva_nomenclatura character varying,
  entidad character varying,
  tipo_identificacion smallint NOT NULL,
  identificacion character varying NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying NOT NULL,
  creation_user character varying NOT NULL,
  nit_empresa character varying NOT NULL DEFAULT '8020220161'::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT entidad_direccion_fk FOREIGN KEY (entidad)
      REFERENCES wsdc.entidad (codigo_suscriptor) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT persona_direccion_fk FOREIGN KEY (tipo_identificacion, identificacion, nit_empresa)
      REFERENCES wsdc.persona (tipo_identificacion, identificacion, nit_empresa) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE wsdc.direccion
  OWNER TO postgres;
COMMENT ON COLUMN wsdc.direccion.tipo IS 'M - Móvil, R - Residencia, L - Laboral';


