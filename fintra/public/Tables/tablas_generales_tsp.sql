-- Table: tablas_generales_tsp

-- DROP TABLE tablas_generales_tsp;

CREATE TABLE tablas_generales_tsp
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
  fecha_envio_ws timestamp without time zone,
  creation_date_real timestamp without time zone DEFAULT now(),
  pk_novedad integer NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE tablas_generales_tsp
  OWNER TO postgres;
GRANT ALL ON TABLE tablas_generales_tsp TO postgres;
GRANT SELECT ON TABLE tablas_generales_tsp TO msoto;
COMMENT ON TABLE tablas_generales_tsp
  IS 'tabla de tsp con novedades de Tablas generales fintra';

-- Trigger: descripcionnulltablasgenerales on tablas_generales_tsp

-- DROP TRIGGER descripcionnulltablasgenerales ON tablas_generales_tsp;

CREATE TRIGGER descripcionnulltablasgenerales
  BEFORE INSERT
  ON tablas_generales_tsp
  FOR EACH ROW
  EXECUTE PROCEDURE descripcionnulltablasgenerales();

-- Trigger: tablasgeneralestspafinvt on tablas_generales_tsp

-- DROP TRIGGER tablasgeneralestspafinvt ON tablas_generales_tsp;

CREATE TRIGGER tablasgeneralestspafinvt
  AFTER INSERT OR UPDATE
  ON tablas_generales_tsp
  FOR EACH ROW
  EXECUTE PROCEDURE tablasgeneralestspafinv();


