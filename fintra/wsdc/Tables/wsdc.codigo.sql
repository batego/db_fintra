-- Table: wsdc.codigo

-- DROP TABLE wsdc.codigo;

CREATE TABLE wsdc.codigo
(
  web_service character varying(1) NOT NULL, -- H - Historia de credito, L - localización
  tabla character varying NOT NULL, -- Nombre de la tabla
  codigo character varying NOT NULL,
  valor character varying NOT NULL,
  descripcion character varying, -- Campo para agregar descripciones en caso de ser necesario.
  tabla_referencia character varying, -- Tabla relacionada
  codigo_referencia character varying, -- Código en la talba relacionada
  equivalencia character varying NOT NULL DEFAULT ''::character varying, -- Equivalencia de este código en las tablas de FINTRA
  creation_user character varying DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE wsdc.codigo
  OWNER TO postgres;
COMMENT ON TABLE wsdc.codigo
  IS 'Tabla que contiene las tablas  de codigos para los dos web services (RECONOCER+ y HC)';
COMMENT ON COLUMN wsdc.codigo.web_service IS 'H - Historia de credito, L - localización';
COMMENT ON COLUMN wsdc.codigo.tabla IS 'Nombre de la tabla';
COMMENT ON COLUMN wsdc.codigo.descripcion IS 'Campo para agregar descripciones en caso de ser necesario.';
COMMENT ON COLUMN wsdc.codigo.tabla_referencia IS 'Tabla relacionada';
COMMENT ON COLUMN wsdc.codigo.codigo_referencia IS 'Código en la talba relacionada';
COMMENT ON COLUMN wsdc.codigo.equivalencia IS 'Equivalencia de este código en las tablas de FINTRA';


