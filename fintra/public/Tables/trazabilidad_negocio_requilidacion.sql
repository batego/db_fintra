-- Table: trazabilidad_negocio_requilidacion

-- DROP TABLE trazabilidad_negocio_requilidacion;

CREATE TABLE trazabilidad_negocio_requilidacion
(
  id serial NOT NULL,
  numero_solicitud integer NOT NULL,
  cod_neg character varying(15) NOT NULL,
  antiguo_numero_cuotas character varying(2) NOT NULL,
  nuevo_numero_cuotas character varying(2) NOT NULL,
  antiguo_valor_negocio numeric(11,2) NOT NULL,
  nuevo_valor_negocio numeric(11,2) NOT NULL,
  antigua_tasa numeric(3,2),
  nueva_tasa numeric(3,2),
  fecha_negocio timestamp without time zone NOT NULL,
  creation_user character varying(12) NOT NULL,
  creation_date timestamp without time zone DEFAULT now()
)
WITH (
  OIDS=FALSE
);
ALTER TABLE trazabilidad_negocio_requilidacion
  OWNER TO postgres;

