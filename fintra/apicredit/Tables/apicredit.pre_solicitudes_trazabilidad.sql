-- Table: apicredit.pre_solicitudes_trazabilidad

-- DROP TABLE apicredit.pre_solicitudes_trazabilidad;

CREATE TABLE apicredit.pre_solicitudes_trazabilidad
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  numero_solicitud integer NOT NULL,
  estado character varying(30) NOT NULL DEFAULT ''::character varying,
  usuario character varying(10) NOT NULL DEFAULT ''::character varying,
  fecha timestamp without time zone NOT NULL DEFAULT now(),
  causal character varying(100) DEFAULT ''::character varying,
  comentarios text NOT NULL DEFAULT ''::text,
  actividad character varying(10)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE apicredit.pre_solicitudes_trazabilidad
  OWNER TO postgres;

