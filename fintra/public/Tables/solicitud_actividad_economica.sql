-- Table: solicitud_actividad_economica

-- DROP TABLE solicitud_actividad_economica;

CREATE TABLE solicitud_actividad_economica
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(6) NOT NULL DEFAULT ''::character varying,
  numero_solicitud integer NOT NULL DEFAULT 0,
  tipo character varying(1) NOT NULL DEFAULT 'S'::character varying,
  ocupacion character varying(15) NOT NULL DEFAULT ''::character varying,
  nombre_empresa character varying(150) NOT NULL DEFAULT ''::character varying,
  nit character varying(15) NOT NULL DEFAULT ''::character varying,
  cargo character varying(60) NOT NULL DEFAULT ''::character varying,
  tipo_contrato character varying(20) NOT NULL DEFAULT ''::character varying,
  fecha_ingreso timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  telefono character varying(15) NOT NULL DEFAULT ''::character varying,
  extension character varying(10) DEFAULT ''::character varying,
  email character varying(100) NOT NULL DEFAULT ''::character varying,
  direccion character varying(100) NOT NULL DEFAULT ''::character varying,
  departameto character varying(10) NOT NULL DEFAULT ''::character varying,
  ciudad character varying(10) NOT NULL DEFAULT ''::character varying,
  salario_ing numeric(15,2) NOT NULL DEFAULT 0.0,
  comisiones_ing numeric(15,2) NOT NULL DEFAULT 0.0,
  honorarios_ing numeric(15,2) NOT NULL DEFAULT 0.0,
  arrendamientos_ing numeric(15,2) NOT NULL DEFAULT 0.0,
  otros_ingresos numeric(15,2) NOT NULL DEFAULT 0.0,
  arriendo_egr numeric(15,2) NOT NULL DEFAULT 0.0,
  prestamo_xnomina numeric(15,2) NOT NULL DEFAULT 0.0,
  gastos_familiares numeric(15,2) NOT NULL DEFAULT 0.0,
  obligciones_finacieras numeric(15,2) NOT NULL DEFAULT 0.0,
  total_activos numeric(15,2) NOT NULL DEFAULT 0.0,
  total_pasivos numeric(15,2) NOT NULL DEFAULT 0.0,
  posee_bienes character varying(1) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(50) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(50) NOT NULL DEFAULT ''::character varying,
  actividad_economica character varying(30) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_solicitud_aval FOREIGN KEY (numero_solicitud)
      REFERENCES solicitud_aval (numero_solicitud) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE solicitud_actividad_economica
  OWNER TO postgres;
GRANT ALL ON TABLE solicitud_actividad_economica TO postgres;
GRANT SELECT ON TABLE solicitud_actividad_economica TO msoto;

-- Trigger: insertsolicitudlaboral on solicitud_actividad_economica

-- DROP TRIGGER insertsolicitudlaboral ON solicitud_actividad_economica;

CREATE TRIGGER insertsolicitudlaboral
  AFTER INSERT
  ON solicitud_actividad_economica
  FOR EACH ROW
  EXECUTE PROCEDURE insert_solicitud_laboral();


