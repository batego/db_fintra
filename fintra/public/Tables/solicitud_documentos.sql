-- Table: solicitud_documentos

-- DROP TABLE solicitud_documentos;

CREATE TABLE solicitud_documentos
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(6) NOT NULL DEFAULT ''::character varying,
  numero_solicitud integer NOT NULL DEFAULT 0,
  num_titulo character varying(15) NOT NULL DEFAULT ''::character varying,
  valor numeric(15,2) NOT NULL DEFAULT 0.0,
  fecha timestamp without time zone NOT NULL DEFAULT now(),
  liquidacion numeric NOT NULL DEFAULT 1,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(50) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(50) NOT NULL DEFAULT ''::character varying,
  comision_aval numeric NOT NULL DEFAULT 0,
  est_indemnizacion character varying(3) NOT NULL DEFAULT ''::character varying,
  devuelto integer NOT NULL DEFAULT 0,
  CONSTRAINT fk_solicitud_aval FOREIGN KEY (numero_solicitud)
      REFERENCES solicitud_aval (numero_solicitud) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE solicitud_documentos
  OWNER TO postgres;
GRANT ALL ON TABLE solicitud_documentos TO postgres;
GRANT SELECT ON TABLE solicitud_documentos TO msoto;

-- Trigger: tu_docs_negocio on solicitud_documentos

-- DROP TRIGGER tu_docs_negocio ON solicitud_documentos;

CREATE TRIGGER tu_docs_negocio
  BEFORE UPDATE
  ON solicitud_documentos
  FOR EACH ROW
  EXECUTE PROCEDURE tu_docs_negocio();


