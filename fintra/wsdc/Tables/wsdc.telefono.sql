-- Table: wsdc.telefono

-- DROP TABLE wsdc.telefono;

CREATE TABLE wsdc.telefono
(
  id integer NOT NULL DEFAULT nextval('wsdc.telefono_secuencia_seq'::regclass),
  tipo character varying, -- M - Móvil, R - Residencia, L - Laboral
  numero bigint NOT NULL,
  nombre_ciudad character varying, -- Nombre de la ciudad del teléfono.
  nombre_departamento character varying,
  codigo_pais integer, -- Para el país se utiliza el ISO-3166.
  codigo_area integer, -- se utiliza la codificación del DANE.
  fuente character varying, -- I - Interna, E - Externa
  creacion character varying,
  actualizacion timestamp without time zone NOT NULL, -- Fecha  de actualizacion
  num_reportes integer, -- cantidad de veces que fué reportado
  entidad character varying,
  reportado character varying,
  tipo_identificacion smallint NOT NULL,
  identificacion character varying NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying NOT NULL,
  creation_user character varying NOT NULL,
  nit_empresa character varying NOT NULL DEFAULT '8020220161'::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT entidad_telefono_fk FOREIGN KEY (entidad)
      REFERENCES wsdc.entidad (codigo_suscriptor) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT persona_telefono_fk FOREIGN KEY (tipo_identificacion, identificacion, nit_empresa)
      REFERENCES wsdc.persona (tipo_identificacion, identificacion, nit_empresa) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE wsdc.telefono
  OWNER TO postgres;
COMMENT ON COLUMN wsdc.telefono.tipo IS 'M - Móvil, R - Residencia, L - Laboral';
COMMENT ON COLUMN wsdc.telefono.nombre_ciudad IS 'Nombre de la ciudad del teléfono.';
COMMENT ON COLUMN wsdc.telefono.codigo_pais IS 'Para el país se utiliza el ISO-3166.';
COMMENT ON COLUMN wsdc.telefono.codigo_area IS 'se utiliza la codificación del DANE.';
COMMENT ON COLUMN wsdc.telefono.fuente IS 'I - Interna, E - Externa';
COMMENT ON COLUMN wsdc.telefono.actualizacion IS 'Fecha  de actualizacion';
COMMENT ON COLUMN wsdc.telefono.num_reportes IS 'cantidad de veces que fué reportado';


