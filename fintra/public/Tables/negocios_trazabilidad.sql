-- Table: negocios_trazabilidad

-- DROP TABLE negocios_trazabilidad;

CREATE TABLE negocios_trazabilidad
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  numero_solicitud integer NOT NULL,
  actividad character varying(10) NOT NULL DEFAULT ''::character varying,
  usuario character varying(10) NOT NULL DEFAULT ''::character varying,
  fecha timestamp without time zone NOT NULL DEFAULT now(),
  cod_neg character varying(15),
  comentarios text NOT NULL DEFAULT ''::text,
  concepto character varying(20) DEFAULT ''::character varying,
  causal character varying(12) DEFAULT ''::character varying,
  comentario_stby text NOT NULL DEFAULT ''::text,
  CONSTRAINT "solicitudavalFK" FOREIGN KEY (numero_solicitud)
      REFERENCES solicitud_aval (numero_solicitud) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE negocios_trazabilidad
  OWNER TO postgres;
GRANT ALL ON TABLE negocios_trazabilidad TO postgres;
GRANT SELECT ON TABLE negocios_trazabilidad TO msoto;

-- Trigger: trazabilidad_negocio_aval on negocios_trazabilidad

-- DROP TRIGGER trazabilidad_negocio_aval ON negocios_trazabilidad;

CREATE TRIGGER trazabilidad_negocio_aval
  BEFORE INSERT
  ON negocios_trazabilidad
  FOR EACH ROW
  EXECUTE PROCEDURE trazabilidad_negocio_aval();


