-- Table: solicitud_laboral

-- DROP TABLE solicitud_laboral;

CREATE TABLE solicitud_laboral
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(6) NOT NULL DEFAULT ''::character varying,
  numero_solicitud integer NOT NULL DEFAULT 0,
  tipo character varying(1) NOT NULL DEFAULT 'S'::character varying,
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
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(50) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(50) NOT NULL DEFAULT ''::character varying,
  id_persona character varying(15) NOT NULL DEFAULT ''::character varying,
  secuencia integer NOT NULL DEFAULT nextval('secuencia_solicitud_seq'::regclass),
  CONSTRAINT fk_solicitud_aval FOREIGN KEY (numero_solicitud)
      REFERENCES solicitud_aval (numero_solicitud) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE solicitud_laboral
  OWNER TO postgres;
GRANT ALL ON TABLE solicitud_laboral TO postgres;
GRANT SELECT ON TABLE solicitud_laboral TO msoto;

