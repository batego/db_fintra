-- Table: apicredit.tab_informacion_laboral

-- DROP TABLE apicredit.tab_informacion_laboral;

CREATE TABLE apicredit.tab_informacion_laboral
(
  id serial NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  numero_solicitud integer NOT NULL,
  tipo character varying(1) NOT NULL DEFAULT 'S'::character varying,
  actividad_economica character varying(30) NOT NULL DEFAULT ''::character varying,
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
  departamento character varying(10) NOT NULL DEFAULT ''::character varying,
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
  creation_user character varying(50) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now()
)
WITH (
  OIDS=FALSE
);
ALTER TABLE apicredit.tab_informacion_laboral
  OWNER TO postgres;

