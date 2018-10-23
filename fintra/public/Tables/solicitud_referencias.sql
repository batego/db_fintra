-- Table: solicitud_referencias

-- DROP TABLE solicitud_referencias;

CREATE TABLE solicitud_referencias
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(6) NOT NULL DEFAULT ''::character varying,
  numero_solicitud integer NOT NULL DEFAULT 0,
  tipo character varying(1) NOT NULL DEFAULT 'S'::character varying,
  tipo_referencia character varying(6) NOT NULL DEFAULT ''::character varying,
  secuencia integer NOT NULL DEFAULT 0,
  nombre character varying(100) NOT NULL DEFAULT ''::character varying,
  primer_apellido character varying(25) NOT NULL DEFAULT ''::character varying,
  segundo_apellido character varying(25) NOT NULL DEFAULT ''::character varying,
  primer_nombre character varying(25) NOT NULL DEFAULT ''::character varying,
  segundo_nombre character varying(25) NOT NULL DEFAULT ''::character varying,
  telefono1 character varying(15) NOT NULL DEFAULT ''::character varying,
  telefono2 character varying(15) NOT NULL DEFAULT ''::character varying,
  extension character varying(6) NOT NULL DEFAULT ''::character varying,
  celular character varying(15) NOT NULL DEFAULT ''::character varying,
  email character varying(100) NOT NULL DEFAULT ''::character varying,
  direccion character varying(160) NOT NULL DEFAULT ''::character varying,
  ciudad character varying(6) NOT NULL DEFAULT ''::character varying,
  departamento character varying(6) NOT NULL DEFAULT ''::character varying,
  tiempo_conocido character varying(15) NOT NULL DEFAULT ''::character varying,
  parentesco character varying(15) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(50) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(50) NOT NULL DEFAULT ''::character varying,
  persona_referencia character varying(15) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_solicitud_aval FOREIGN KEY (numero_solicitud)
      REFERENCES solicitud_aval (numero_solicitud) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE solicitud_referencias
  OWNER TO postgres;
GRANT ALL ON TABLE solicitud_referencias TO postgres;
GRANT SELECT ON TABLE solicitud_referencias TO msoto;

