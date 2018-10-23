-- Table: importacion_parametros

-- DROP TABLE importacion_parametros;

CREATE TABLE importacion_parametros
(
  tabla character varying(40) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(40) NOT NULL DEFAULT ''::character varying,
  ctab character varying(1) NOT NULL DEFAULT 'T'::character varying,
  fcon character varying(1) NOT NULL DEFAULT 'N'::character varying,
  adat character varying(1) NOT NULL DEFAULT 'A'::character varying,
  bpna character varying(1) NOT NULL DEFAULT 'C'::character varying,
  usuario_creacion character varying(40) NOT NULL DEFAULT ''::character varying,
  fecha_creacion timestamp without time zone NOT NULL DEFAULT now(),
  usuario_actualizacion character varying(40) NOT NULL DEFAULT ''::character varying,
  fecha_actualizacion timestamp without time zone NOT NULL DEFAULT now(),
  evento character varying NOT NULL DEFAULT ''::character varying, -- Evento a ejecutar segun sea el archivo de importacion
  titulo character varying(1) NOT NULL DEFAULT 'S'::character varying, -- Indica si el archivo de importacion contiene o no titulo en su cabecera
  formato character varying(40) NOT NULL DEFAULT ''::character varying, -- Nombre del Formato
  insert character varying(1) NOT NULL DEFAULT 'S'::character varying, -- Indica si el formato es valido para grabar datos
  update character varying(1) NOT NULL DEFAULT 'N'::character varying, -- Indica si el formato es valido para grabar datos
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE importacion_parametros
  OWNER TO postgres;
GRANT ALL ON TABLE importacion_parametros TO postgres;
GRANT SELECT ON TABLE importacion_parametros TO msoto;
COMMENT ON COLUMN importacion_parametros.evento IS 'Evento a ejecutar segun sea el archivo de importacion';
COMMENT ON COLUMN importacion_parametros.titulo IS 'Indica si el archivo de importacion contiene o no titulo en su cabecera';
COMMENT ON COLUMN importacion_parametros.formato IS 'Nombre del Formato';
COMMENT ON COLUMN importacion_parametros.insert IS 'Indica si el formato es valido para grabar datos';
COMMENT ON COLUMN importacion_parametros.update IS 'Indica si el formato es valido para grabar datos';


