-- Table: errores_envio_correo

-- DROP TABLE errores_envio_correo;

CREATE TABLE errores_envio_correo
(
  id serial NOT NULL,
  proceso character varying(10) NOT NULL DEFAULT ''::character varying,
  descripcion text NOT NULL DEFAULT ''::character varying,
  detalle_error text NOT NULL DEFAULT ''::character varying,
  usuario character varying(50) NOT NULL DEFAULT ''::character varying,
  fecha timestamp without time zone NOT NULL DEFAULT now()
)
WITH (
  OIDS=FALSE
);
ALTER TABLE errores_envio_correo
  OWNER TO postgres;
GRANT ALL ON TABLE errores_envio_correo TO postgres;
GRANT SELECT ON TABLE errores_envio_correo TO msoto;

