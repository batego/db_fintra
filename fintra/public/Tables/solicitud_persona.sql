-- Table: solicitud_persona

-- DROP TABLE solicitud_persona;

CREATE TABLE solicitud_persona
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(6) NOT NULL DEFAULT ''::character varying,
  numero_solicitud integer NOT NULL DEFAULT 0,
  tipo_persona character varying(6) NOT NULL DEFAULT ''::character varying,
  tipo character varying(1) NOT NULL DEFAULT 'S'::character varying,
  codcli character varying(15) NOT NULL DEFAULT ''::character varying,
  primer_apellido character varying(25) NOT NULL DEFAULT ''::character varying,
  segundo_apellido character varying(25) NOT NULL DEFAULT ''::character varying,
  primer_nombre character varying(25) NOT NULL DEFAULT ''::character varying,
  segundo_nombre character varying(25) NOT NULL DEFAULT ''::character varying,
  nombre character varying(100) NOT NULL DEFAULT ''::character varying,
  ciudad character varying(30) NOT NULL DEFAULT ''::character varying,
  genero character varying(1) NOT NULL DEFAULT ''::character varying,
  estado_civil character varying(1) NOT NULL DEFAULT ''::character varying,
  direccion character varying(160) NOT NULL DEFAULT ''::character varying,
  departamento character varying(10) NOT NULL DEFAULT ''::character varying,
  barrio character varying(100) NOT NULL DEFAULT ''::character varying,
  identificacion character varying(15) NOT NULL DEFAULT ''::character varying,
  tipo_id character varying(3) NOT NULL DEFAULT 'CED'::character varying,
  fecha_expedicion_id timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  ciudad_expedicion_id character varying(6) NOT NULL DEFAULT ''::character varying,
  dpto_expedicion_id character varying(6) NOT NULL DEFAULT ''::character varying,
  fecha_nacimiento timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  ciudad_nacimiento character varying(6) NOT NULL DEFAULT ''::character varying,
  dpto_nacimiento character varying(6) NOT NULL DEFAULT ''::character varying,
  nivel_estudio character varying(15) NOT NULL DEFAULT ''::character varying,
  profesion character varying(60) DEFAULT ''::character varying,
  personas_a_cargo integer NOT NULL DEFAULT 0,
  num_de_hijos integer NOT NULL DEFAULT 0,
  total_grupo_familiar integer NOT NULL DEFAULT 0,
  estrato integer NOT NULL DEFAULT 0,
  tiempo_residencia character varying(20) NOT NULL DEFAULT ''::character varying,
  tipo_vivienda character varying(30) NOT NULL DEFAULT ''::character varying,
  telefono character varying(15) NOT NULL DEFAULT ''::character varying,
  celular character varying(15) NOT NULL DEFAULT ''::character varying,
  email character varying(100) NOT NULL DEFAULT ''::character varying,
  telefono2 character varying(15) NOT NULL DEFAULT ''::character varying,
  primer_apellido_cony character varying(25) NOT NULL DEFAULT ''::character varying,
  segundo_apellido_cony character varying(25) NOT NULL DEFAULT ''::character varying,
  primer_nombre_cony character varying(25) NOT NULL DEFAULT ''::character varying,
  segundo_nombre_cony character varying(25) NOT NULL DEFAULT ''::character varying,
  tipo_id_cony character varying(3) NOT NULL DEFAULT ''::character varying,
  id_cony character varying(15) NOT NULL DEFAULT ''::character varying,
  empresa_cony character varying(50) NOT NULL DEFAULT ''::character varying,
  direccion_cony character varying(160) NOT NULL DEFAULT ''::character varying,
  telefono_cony character varying(15) NOT NULL DEFAULT ''::character varying,
  salario_cony numeric(15,2) NOT NULL DEFAULT 0,
  celular_cony character varying(15) NOT NULL DEFAULT ''::character varying,
  email_cony character varying(100) NOT NULL DEFAULT ''::character varying,
  cargo_cony character varying(60) NOT NULL DEFAULT ''::character varying,
  ciiu character varying(15) NOT NULL DEFAULT ''::character varying,
  fax character varying(15) NOT NULL DEFAULT ''::character varying,
  tipo_empresa character varying(15) NOT NULL DEFAULT ''::character varying,
  fecha_constitucion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  representante_legal character varying(60) NOT NULL DEFAULT ''::character varying,
  genero_representante character varying(1) NOT NULL DEFAULT ''::character varying,
  tipo_id_representante character varying(3) NOT NULL DEFAULT ''::character varying,
  id_representante character varying(15) NOT NULL DEFAULT ''::character varying,
  firmador_cheques character varying(60) NOT NULL DEFAULT ''::character varying,
  genero_firmador character varying(1) NOT NULL DEFAULT ''::character varying,
  tipo_id_firmador character varying(3) NOT NULL DEFAULT ''::character varying,
  id_firmador character varying(15) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(50) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(50) NOT NULL DEFAULT ''::character varying,
  estado_civil_padres character varying(30) NOT NULL DEFAULT ''::character varying,
  secuencia integer NOT NULL DEFAULT nextval('secuencia_solicitud_seq'::regclass),
  posee_bienes character varying(1) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_solicitud_aval FOREIGN KEY (numero_solicitud)
      REFERENCES solicitud_aval (numero_solicitud) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE solicitud_persona
  OWNER TO postgres;
GRANT ALL ON TABLE solicitud_persona TO postgres;
GRANT SELECT ON TABLE solicitud_persona TO msoto;

-- Trigger: actualizar_nombre on solicitud_persona

-- DROP TRIGGER actualizar_nombre ON solicitud_persona;

CREATE TRIGGER actualizar_nombre
  AFTER INSERT
  ON solicitud_persona
  FOR EACH ROW
  EXECUTE PROCEDURE actualizar_nombre_cliente();


