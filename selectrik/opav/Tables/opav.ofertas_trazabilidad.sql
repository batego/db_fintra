-- Table: opav.ofertas_trazabilidad

-- DROP TABLE opav.ofertas_trazabilidad;

CREATE TABLE opav.ofertas_trazabilidad
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id_solicitud integer NOT NULL,
  etapa character varying(10) NOT NULL DEFAULT ''::character varying,
  usuario character varying(10) NOT NULL DEFAULT ''::character varying,
  fecha timestamp without time zone NOT NULL DEFAULT now(),
  comentarios text NOT NULL DEFAULT ''::text,
  concepto character varying(20) DEFAULT ''::character varying,
  causal character varying(12) DEFAULT ''::character varying,
  CONSTRAINT "idsolicitudFK" FOREIGN KEY (id_solicitud)
      REFERENCES opav.ofertas (id_solicitud) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.ofertas_trazabilidad
  OWNER TO postgres;
