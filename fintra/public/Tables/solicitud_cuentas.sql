-- Table: solicitud_cuentas

-- DROP TABLE solicitud_cuentas;

CREATE TABLE solicitud_cuentas
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(6) NOT NULL DEFAULT ''::character varying,
  numero_solicitud integer NOT NULL DEFAULT 0,
  consecutivo integer NOT NULL DEFAULT 0,
  tipo character varying(15) NOT NULL DEFAULT ''::character varying,
  banco character varying(60) NOT NULL DEFAULT ''::character varying,
  cuenta character varying(20) NOT NULL DEFAULT ''::character varying,
  fecha_apertura timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  numero_tarjeta character varying(20) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(50) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(50) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_solicitud_aval FOREIGN KEY (numero_solicitud)
      REFERENCES solicitud_aval (numero_solicitud) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE solicitud_cuentas
  OWNER TO postgres;
GRANT ALL ON TABLE solicitud_cuentas TO postgres;
GRANT SELECT ON TABLE solicitud_cuentas TO msoto;

