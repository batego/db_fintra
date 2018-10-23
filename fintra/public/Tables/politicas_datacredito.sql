-- Table: politicas_datacredito

-- DROP TABLE politicas_datacredito;

CREATE TABLE politicas_datacredito
(
  id_politica serial NOT NULL,
  nombre character varying(100) NOT NULL,
  central_riesgo character varying(20) NOT NULL,
  unidad_negocio character varying(20) NOT NULL,
  id_convenio integer NOT NULL,
  edad_ini integer,
  edad_fin integer,
  monto_ini integer,
  monto_fin integer,
  agencia_cobro character varying(5),
  estado character varying(1) NOT NULL DEFAULT 'A'::character varying,
  monto boolean NOT NULL,
  agencia boolean NOT NULL,
  edad boolean NOT NULL,
  tipo_reporte character varying(20) DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE politicas_datacredito
  OWNER TO postgres;
GRANT ALL ON TABLE politicas_datacredito TO postgres;
GRANT SELECT ON TABLE politicas_datacredito TO msoto;

