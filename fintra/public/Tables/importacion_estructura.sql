-- Table: importacion_estructura

-- DROP TABLE importacion_estructura;

CREATE TABLE importacion_estructura
(
  tabla character varying(40) NOT NULL DEFAULT ''::character varying,
  sec numeric NOT NULL DEFAULT 0,
  campo character varying(40) NOT NULL DEFAULT ''::character varying,
  tipo character varying(200) NOT NULL DEFAULT ''::character varying,
  extra character varying(40) NOT NULL DEFAULT ''::character varying,
  usuario_creacion character varying(40) NOT NULL DEFAULT ''::character varying,
  fecha_creacion timestamp without time zone NOT NULL DEFAULT now(),
  usuario_actualizacion character varying(40) NOT NULL DEFAULT ''::character varying,
  fecha_actualizacion timestamp without time zone NOT NULL DEFAULT now(),
  tiene_default character varying(1) NOT NULL DEFAULT 'N'::character varying, -- Indica si este campo contendra un valor default en caso de no estar definido en el archivo de importacion
  tipo_default character varying(25) NOT NULL DEFAULT ''::character varying, -- Tipo default que se le asignara a este campo dependiendo del archivo de importacion
  valor_default character varying NOT NULL DEFAULT ''::character varying, -- Valor default del campo en archivo de excel
  alias character varying(40) NOT NULL DEFAULT ''::character varying, -- Alias del campo
  validacion text NOT NULL DEFAULT ''::text, -- Validacion de la...
  insercion text NOT NULL DEFAULT ''::text, -- (SQL) que indica la...
  formato character varying(40) NOT NULL DEFAULT ''::character varying, -- Nombre del Formato
  aplica_update character(1) NOT NULL DEFAULT 'N'::bpchar, -- Indica si el campo se puede actualizar o no dentro del formato
  obs_validacion character varying(200) NOT NULL DEFAULT ''::character varying, -- Descripcion del campo de validacion
  obs_insercion character varying(200) NOT NULL DEFAULT ''::character varying, -- Descripcion del campo de insercion
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE importacion_estructura
  OWNER TO postgres;
GRANT ALL ON TABLE importacion_estructura TO postgres;
GRANT SELECT ON TABLE importacion_estructura TO msoto;
COMMENT ON COLUMN importacion_estructura.tiene_default IS 'Indica si este campo contendra un valor default en caso de no estar definido en el archivo de importacion';
COMMENT ON COLUMN importacion_estructura.tipo_default IS 'Tipo default que se le asignara a este campo dependiendo del archivo de importacion';
COMMENT ON COLUMN importacion_estructura.valor_default IS 'Valor default del campo en archivo de excel';
COMMENT ON COLUMN importacion_estructura.alias IS 'Alias del campo';
COMMENT ON COLUMN importacion_estructura.validacion IS 'Validacion de la
informacion del campo (SQL)';
COMMENT ON COLUMN importacion_estructura.insercion IS '(SQL) que indica la
fuente de donde se extraera el dato';
COMMENT ON COLUMN importacion_estructura.formato IS 'Nombre del Formato';
COMMENT ON COLUMN importacion_estructura.aplica_update IS 'Indica si el campo se puede actualizar o no dentro del formato';
COMMENT ON COLUMN importacion_estructura.obs_validacion IS 'Descripcion del campo de validacion';
COMMENT ON COLUMN importacion_estructura.obs_insercion IS 'Descripcion del campo de insercion';


