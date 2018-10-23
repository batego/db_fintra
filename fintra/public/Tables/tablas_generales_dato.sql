-- Table: tablas_generales_dato

-- DROP TABLE tablas_generales_dato;

CREATE TABLE tablas_generales_dato
(
  reg_status character varying(1) DEFAULT ''::character varying,
  dstrct character varying(4) DEFAULT ''::character varying,
  table_type character varying(10) NOT NULL DEFAULT ''::character varying,
  secuencia character varying(10) NOT NULL DEFAULT ''::character varying,
  leyenda text DEFAULT ''::character varying,
  tipo character varying(20) DEFAULT ''::character varying,
  longitud numeric NOT NULL DEFAULT 1,
  last_update timestamp without time zone NOT NULL DEFAULT '2005-12-21 10:04:04.562'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT '2005-12-21 10:04:04.562'::timestamp without time zone,
  creation_user character varying(10) DEFAULT ''::character varying,
  base character varying(3) DEFAULT ''::character varying,
  sql text NOT NULL DEFAULT ''::text -- SQL para generar la lista de valores
)
WITH (
  OIDS=TRUE
);
ALTER TABLE tablas_generales_dato
  OWNER TO postgres;
GRANT ALL ON TABLE tablas_generales_dato TO postgres;
GRANT SELECT ON TABLE tablas_generales_dato TO msoto;
COMMENT ON TABLE tablas_generales_dato
  IS 'Tabla de definicion de campos a las tablas generales fintra';
COMMENT ON COLUMN tablas_generales_dato.sql IS 'SQL para generar la lista de valores';


