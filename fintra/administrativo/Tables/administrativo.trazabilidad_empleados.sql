-- Table: administrativo.trazabilidad_empleados

-- DROP TABLE administrativo.trazabilidad_empleados;

CREATE TABLE administrativo.trazabilidad_empleados
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  ciudad character varying(10) NOT NULL DEFAULT ''::character varying,
  id_cargo integer NOT NULL,
  id_tipo_contrato integer NOT NULL,
  id_tipo_doc integer NOT NULL,
  id_riesgo_cargo integer NOT NULL,
  id_entidad_salud integer NOT NULL,
  id_riesgos_laboral integer NOT NULL,
  id_fondo_pensiones integer NOT NULL,
  id_cesantias integer NOT NULL,
  id_caja_compensacion serial NOT NULL,
  id_estado_civil integer NOT NULL,
  nombre_completo character varying(200) NOT NULL DEFAULT ''::character varying,
  identificacion character varying(15) NOT NULL DEFAULT ''::character varying,
  ciudad_expedicion character varying(10) NOT NULL DEFAULT ''::character varying,
  banco_transfer character varying(15) NOT NULL DEFAULT ''::character varying,
  tipo_cuenta character varying(15) NOT NULL DEFAULT ''::character varying,
  no_cuenta character varying(20) NOT NULL DEFAULT ''::character varying,
  libreta_militar character varying(15) NOT NULL DEFAULT ''::character varying,
  fecha_ingreso timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  direccion character varying(160) NOT NULL DEFAULT ''::character varying,
  telefono character varying(15) NOT NULL DEFAULT ''::character varying,
  celular character varying(15) NOT NULL DEFAULT ''::character varying,
  email character varying(100) NOT NULL DEFAULT ''::character varying,
  fecha_nacimiento timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  ciudad_nacimiento character varying(6) NOT NULL DEFAULT ''::character varying,
  sexo character varying(10) NOT NULL DEFAULT ''::character varying,
  nivel_estudio character varying(15) NOT NULL DEFAULT ''::character varying,
  personas_a_cargo integer NOT NULL DEFAULT 0,
  num_de_hijos integer NOT NULL DEFAULT 0,
  total_grupo_familiar integer NOT NULL DEFAULT 0,
  fecha_retiro timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  observaciones character varying(200) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(10) DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  id_nivel_estudio integer,
  departamento character varying(10),
  dpto_nacimiento character varying(10),
  dpto_expedicion character varying(10),
  fecha_expedicion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  id_nivel_jerarquico integer NOT NULL,
  id_profesion integer NOT NULL,
  duracion_contrato integer DEFAULT 0,
  salario numeric(11,2),
  id_proceso_meta integer,
  id_proceso_interno integer,
  id_linea_negocio integer,
  id_producto integer,
  tipo_vivienda character varying(10),
  barrio integer,
  causal_retiro character varying,
  CONSTRAINT empleados_ciudad_expedicion_id_fkey FOREIGN KEY (ciudad_expedicion)
      REFERENCES ciudad (codciu) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT empleados_ciudad_fkey FOREIGN KEY (ciudad)
      REFERENCES ciudad (codciu) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT empleados_ciudad_nacimiento_fkey FOREIGN KEY (ciudad_nacimiento)
      REFERENCES ciudad (codciu) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT empleados_departamento_fkey FOREIGN KEY (departamento)
      REFERENCES estado (department_code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT empleados_dpto_nacimiento_fkey FOREIGN KEY (dpto_nacimiento)
      REFERENCES estado (department_code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT empleados_id_caja_compensacion_fkey FOREIGN KEY (id_caja_compensacion)
      REFERENCES administrativo.caja_compensacion (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT empleados_id_cargo_fkey FOREIGN KEY (id_cargo)
      REFERENCES administrativo.cargos (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT empleados_id_cesantias_fkey FOREIGN KEY (id_cesantias)
      REFERENCES administrativo.fondo_pensiones (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT empleados_id_entidad_salud_fkey FOREIGN KEY (id_entidad_salud)
      REFERENCES administrativo.entidades_salud (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT empleados_id_estado_civil_fkey FOREIGN KEY (id_estado_civil)
      REFERENCES estado_civil (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT empleados_id_fondo_pensiones_fkey FOREIGN KEY (id_fondo_pensiones)
      REFERENCES administrativo.fondo_pensiones (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT empleados_id_linea_negocio_fkey FOREIGN KEY (id_linea_negocio)
      REFERENCES unidad_negocio (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT empleados_id_nivel_estudio_fkey FOREIGN KEY (id_nivel_estudio)
      REFERENCES nivel_estudio (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT empleados_id_nivel_jerarquico_fkey FOREIGN KEY (id_nivel_jerarquico)
      REFERENCES administrativo.niveles_jerarquicos (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT empleados_id_proceso_interno_fkey FOREIGN KEY (id_proceso_interno)
      REFERENCES proceso_interno (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT empleados_id_proceso_meta_fkey FOREIGN KEY (id_proceso_meta)
      REFERENCES proceso_meta (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT empleados_id_profesion_fkey FOREIGN KEY (id_profesion)
      REFERENCES administrativo.profesiones (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT empleados_id_profesion_fkey1 FOREIGN KEY (id_profesion)
      REFERENCES administrativo.profesiones (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT empleados_id_riesgo_cargo_fkey FOREIGN KEY (id_riesgo_cargo)
      REFERENCES administrativo.riesgo_cargos (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT empleados_id_riesgos_laboral_fkey FOREIGN KEY (id_riesgos_laboral)
      REFERENCES administrativo.riesgos_laborales (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT empleados_id_tipo_contrato_fkey FOREIGN KEY (id_tipo_contrato)
      REFERENCES administrativo.tipo_contrato (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT empleados_id_tipo_doc_fkey FOREIGN KEY (id_tipo_doc)
      REFERENCES administrativo.tipo_doc (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.trazabilidad_empleados
  OWNER TO postgres;

