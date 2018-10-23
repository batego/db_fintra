-- Table: solicitud_finanzas

-- DROP TABLE solicitud_finanzas;

CREATE TABLE solicitud_finanzas
(
  reg_status character varying(1) DEFAULT ''::character varying,
  dstrct character varying(6) DEFAULT ''::character varying,
  numero_solicitud integer NOT NULL DEFAULT 0,
  tipo character varying(1) NOT NULL DEFAULT 'S'::character varying,
  id_persona character varying(15) DEFAULT ''::character varying,
  salario numeric(15,2) NOT NULL DEFAULT 0.0,
  honorarios numeric(15,2) NOT NULL DEFAULT 0.0,
  otros_ingresos numeric(15,2) NOT NULL DEFAULT 0.0,
  total_ingresos numeric(15,2) NOT NULL DEFAULT 0.0,
  descuento_nomina numeric(15,2) NOT NULL DEFAULT 0.0,
  gastos_arriendo numeric(15,2) NOT NULL DEFAULT 0.0,
  gastos_creditos numeric(15,2) NOT NULL DEFAULT 0.0,
  otros_gastos numeric(15,2) NOT NULL DEFAULT 0.0,
  total_egresos numeric(15,2) NOT NULL DEFAULT 0.0,
  activos numeric(15,2) NOT NULL DEFAULT 0.0,
  pasivos numeric(15,2) NOT NULL DEFAULT 0.0,
  total_patrimonio numeric(15,2) NOT NULL DEFAULT 0.0,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(50) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(50) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_sf_sol_aval FOREIGN KEY (numero_solicitud)
      REFERENCES solicitud_aval (numero_solicitud) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE solicitud_finanzas
  OWNER TO postgres;
GRANT ALL ON TABLE solicitud_finanzas TO postgres;
GRANT SELECT ON TABLE solicitud_finanzas TO msoto;

