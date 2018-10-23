-- Table: solicitud_bienes

-- DROP TABLE solicitud_bienes;

CREATE TABLE solicitud_bienes
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(6) NOT NULL DEFAULT ''::character varying,
  numero_solicitud integer NOT NULL DEFAULT 0,
  tipo character varying(1) NOT NULL DEFAULT 'S'::character varying,
  secuencia integer NOT NULL DEFAULT 0,
  tipo_de_bien character varying(15) NOT NULL DEFAULT ''::character varying,
  hipoteca character varying(1) NOT NULL DEFAULT 'N'::character varying,
  a_favor_de character varying(60) NOT NULL DEFAULT ''::character varying,
  valor_comercial numeric(15,2) NOT NULL DEFAULT 0.0,
  direccion character varying(60) NOT NULL DEFAULT ''::character varying,
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
ALTER TABLE solicitud_bienes
  OWNER TO postgres;
GRANT ALL ON TABLE solicitud_bienes TO postgres;
GRANT SELECT ON TABLE solicitud_bienes TO msoto;

