-- Table: sp2

-- DROP TABLE sp2;

CREATE TABLE sp2
(
  reg_status character varying(1),
  dstrct character varying(6),
  numero_solicitud integer,
  tipo_persona character varying(6),
  tipo character varying(1),
  codcli character varying(15),
  primer_apellido character varying(25),
  segundo_apellido character varying(25),
  primer_nombre character varying(25),
  segundo_nombre character varying(25),
  nombre character varying(100),
  ciudad character varying(30),
  genero character varying(1),
  estado_civil character varying(1),
  direccion character varying(160),
  departamento character varying(10),
  barrio character varying(100),
  identificacion character varying(15),
  tipo_id character varying(3),
  fecha_expedicion_id timestamp without time zone,
  ciudad_expedicion_id character varying(6),
  dpto_expedicion_id character varying(6),
  fecha_nacimiento timestamp without time zone,
  ciudad_nacimiento character varying(6),
  dpto_nacimiento character varying(6),
  nivel_estudio character varying(15),
  profesion character varying(60),
  personas_a_cargo integer,
  num_de_hijos integer,
  total_grupo_familiar integer,
  estrato integer,
  tiempo_residencia character varying(20),
  tipo_vivienda character varying(30),
  telefono character varying(15),
  celular character varying(15),
  email character varying(100),
  telefono2 character varying(15),
  primer_apellido_cony character varying(25),
  segundo_apellido_cony character varying(25),
  primer_nombre_cony character varying(25),
  segundo_nombre_cony character varying(25),
  tipo_id_cony character varying(3),
  id_cony character varying(15),
  empresa_cony character varying(50),
  direccion_cony character varying(160),
  telefono_cony character varying(15),
  salario_cony numeric(15,2),
  celular_cony character varying(15),
  email_cony character varying(100),
  cargo_cony character varying(60),
  ciiu character varying(15),
  fax character varying(15),
  tipo_empresa character varying(15),
  fecha_constitucion timestamp without time zone,
  representante_legal character varying(60),
  genero_representante character varying(1),
  tipo_id_representante character varying(3),
  id_representante character varying(15),
  firmador_cheques character varying(60),
  genero_firmador character varying(1),
  tipo_id_firmador character varying(3),
  id_firmador character varying(15),
  creation_date timestamp without time zone,
  creation_user character varying(15),
  last_update timestamp without time zone,
  user_update character varying(15)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE sp2
  OWNER TO postgres;
GRANT ALL ON TABLE sp2 TO postgres;
GRANT SELECT ON TABLE sp2 TO msoto;

