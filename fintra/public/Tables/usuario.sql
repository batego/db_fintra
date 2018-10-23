-- Table: usuario

-- DROP TABLE usuario;

CREATE TABLE usuario
(
  login character varying(12),
  password character varying(12),
  nombre character varying(60),
  estado character varying(12) DEFAULT 1,
  fecha_ultimo_cambio_estado timestamp without time zone DEFAULT '1900-01-01 00:00:00'::timestamp without time zone,
  id_perfil numeric(12,0),
  id_agencia character varying(12),
  id_mims character varying(12),
  cedula character varying(12),
  email character varying(60) NOT NULL DEFAULT ''::character varying, -- E-mail del usuario
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE usuario
  OWNER TO postgres;
GRANT ALL ON TABLE usuario TO postgres;
GRANT SELECT ON TABLE usuario TO msoto;
COMMENT ON COLUMN usuario.email IS 'E-mail del usuario';


