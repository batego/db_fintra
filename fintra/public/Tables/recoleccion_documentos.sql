-- Table: recoleccion_documentos

-- DROP TABLE recoleccion_documentos;

CREATE TABLE recoleccion_documentos
(
  numero_solicitud integer NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT 'FINV'::character varying,
  nombre_titular character varying NOT NULL DEFAULT ''::character varying,
  cedula_titular character varying NOT NULL DEFAULT ''::character varying,
  direccion1_titular character varying NOT NULL DEFAULT ''::character varying,
  direccion2_titular character varying NOT NULL DEFAULT ''::character varying,
  telefono_titular character varying NOT NULL DEFAULT ''::character varying,
  celular_titular character varying NOT NULL DEFAULT ''::character varying,
  nombre_codeudor character varying NOT NULL DEFAULT ''::character varying,
  cedula_codeudor character varying NOT NULL DEFAULT ''::character varying,
  direccion1_codeudor character varying NOT NULL DEFAULT ''::character varying,
  direccion2_codeudor character varying NOT NULL DEFAULT ''::character varying,
  telefono_codeudor character varying NOT NULL DEFAULT ''::character varying,
  celular_codeudor character varying NOT NULL DEFAULT ''::character varying,
  negocio character varying NOT NULL DEFAULT ''::character varying,
  fecha_solicitud timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  fecha_entrega_trans timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  fecha_recivido_trans timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  entregado character varying(1) NOT NULL DEFAULT 'N'::character varying,
  empresa character varying NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  observaciones text NOT NULL DEFAULT ''::text,
  CONSTRAINT fk_recoleccion_documentos FOREIGN KEY (numero_solicitud)
      REFERENCES solicitud_aval (numero_solicitud) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE recoleccion_documentos
  OWNER TO postgres;
GRANT ALL ON TABLE recoleccion_documentos TO postgres;
GRANT SELECT ON TABLE recoleccion_documentos TO msoto;

