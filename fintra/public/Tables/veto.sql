-- Table: veto

-- DROP TABLE veto;

CREATE TABLE veto
(
  estado character varying(1) DEFAULT 'A'::character varying,
  estadovetop character varying(1) DEFAULT 'A'::character varying,
  fechlevveto date,
  viajesveto integer NOT NULL DEFAULT 0,
  fechaingre date NOT NULL DEFAULT now(),
  codigo character varying(15) NOT NULL,
  tipocodigo character varying(1) NOT NULL DEFAULT ''::character varying,
  totalvetos integer NOT NULL DEFAULT 0,
  fechaultveto date NOT NULL DEFAULT '0099-01-01'::date,
  fechaultlevveto date NOT NULL DEFAULT '0099-01-01'::date,
  fechaultact timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  usuario character varying(100),
  tipoveto integer NOT NULL,
  vetopago numeric(1,0) NOT NULL DEFAULT 0,
  vetoviaje numeric(1,0) NOT NULL DEFAULT 0,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE veto
  OWNER TO postgres;
GRANT ALL ON TABLE veto TO postgres;
GRANT SELECT ON TABLE veto TO msoto;

