-- Table: configuracion_envio_correo

-- DROP TABLE configuracion_envio_correo;

CREATE TABLE configuracion_envio_correo
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  proceso character varying(10) NOT NULL DEFAULT ''::character varying,
  servidor character varying(50) NOT NULL DEFAULT ''::character varying,
  puerto character varying(10) NOT NULL DEFAULT ''::character varying,
  usuario character varying(50) NOT NULL DEFAULT ''::character varying,
  clave character varying(50) NOT NULL DEFAULT ''::character varying,
  bodymessage text NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE configuracion_envio_correo
  OWNER TO postgres;
GRANT ALL ON TABLE configuracion_envio_correo TO postgres;
GRANT SELECT ON TABLE configuracion_envio_correo TO msoto;

