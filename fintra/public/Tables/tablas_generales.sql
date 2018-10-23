-- Table: tablas_generales

-- DROP TABLE tablas_generales;

CREATE TABLE tablas_generales
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  table_type character varying(10) NOT NULL DEFAULT ''::character varying,
  table_code character varying(30) NOT NULL DEFAULT ''::character varying,
  referencia character varying(50) NOT NULL DEFAULT ''::character varying,
  descripcion text NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  dato text NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE tablas_generales
  OWNER TO postgres;
GRANT ALL ON TABLE tablas_generales TO postgres;
GRANT SELECT ON TABLE tablas_generales TO msoto;
COMMENT ON TABLE tablas_generales
  IS 'Tablas generales fintra';

