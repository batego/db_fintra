-- Table: mc_sr_121205

-- DROP TABLE mc_sr_121205;

CREATE TABLE mc_sr_121205
(
  reg_status character varying(1),
  dstrct character varying(6),
  numero_solicitud integer,
  tipo character varying(1),
  tipo_referencia character varying(6),
  secuencia integer,
  nombre character varying(100),
  primer_apellido character varying(25),
  segundo_apellido character varying(25),
  primer_nombre character varying(25),
  segundo_nombre character varying(25),
  telefono1 character varying(15),
  telefono2 character varying(15),
  extension character varying(6),
  celular character varying(15),
  email character varying(100),
  direccion character varying(160),
  ciudad character varying(6),
  departamento character varying(6),
  tiempo_conocido character varying(15),
  parentesco character varying(15),
  creation_date timestamp without time zone,
  creation_user character varying(50),
  last_update timestamp without time zone,
  user_update character varying(50),
  persona_referencia character varying(15)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE mc_sr_121205
  OWNER TO postgres;

