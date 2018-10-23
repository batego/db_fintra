-- Table: apicredit.tab_cons_solicitud_laboral

-- DROP TABLE apicredit.tab_cons_solicitud_laboral;

CREATE TABLE apicredit.tab_cons_solicitud_laboral
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(6) NOT NULL DEFAULT ''::character varying,
  numero_solicitud integer NOT NULL DEFAULT 0,
  tipo character varying(1) NOT NULL DEFAULT 'S'::character varying,
  secuencia integer NOT NULL DEFAULT 0,
  ocupacion character varying(15) NOT NULL DEFAULT ''::character varying,
  actividad_economica character varying(60) NOT NULL DEFAULT ''::character varying,
  nombre_empresa character varying(150) NOT NULL DEFAULT ''::character varying,
  nit character varying(15) NOT NULL DEFAULT ''::character varying,
  direccion character varying(100) NOT NULL DEFAULT ''::character varying,
  ciudad character varying(6) NOT NULL DEFAULT ''::character varying,
  departamento character varying(6) NOT NULL DEFAULT ''::character varying,
  telefono character varying(15) NOT NULL DEFAULT ''::character varying,
  extension character varying(10) DEFAULT ''::character varying,
  cargo character varying(60) NOT NULL DEFAULT ''::character varying,
  fecha_ingreso timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  tipo_contrato character varying(20) NOT NULL DEFAULT ''::character varying,
  negocio_propio character varying(1) NOT NULL DEFAULT ''::character varying,
  salario numeric(15,2) NOT NULL DEFAULT 0.0,
  celular character varying(15) NOT NULL DEFAULT ''::character varying,
  email character varying(100) NOT NULL DEFAULT ''::character varying,
  eps character varying(100) NOT NULL DEFAULT ''::character varying,
  tipo_afiliacion character varying(15) NOT NULL DEFAULT ''::character varying,
  direccion_cobro character varying(100) NOT NULL DEFAULT ''::character varying,
  otros_ingresos numeric(15,2) NOT NULL DEFAULT 0.0,
  concepto_otros_ing character varying(150) NOT NULL DEFAULT ''::character varying,
  gastos_manutencion numeric(15,2) NOT NULL DEFAULT 0.0,
  gastos_creditos numeric(15,2) NOT NULL DEFAULT 0.0,
  gastos_arriendo numeric(15,2) NOT NULL DEFAULT 0.0,
  id_persona character varying(15) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(50) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE apicredit.tab_cons_solicitud_laboral
  OWNER TO postgres;

