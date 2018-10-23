-- Table: solicitud_obligaciones_comprar

-- DROP TABLE solicitud_obligaciones_comprar;

CREATE TABLE solicitud_obligaciones_comprar
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(6) NOT NULL DEFAULT ''::character varying,
  numero_solicitud integer NOT NULL DEFAULT 0,
  secuencia integer NOT NULL DEFAULT 0,
  nit_entidad character varying(15) NOT NULL DEFAULT ''::character varying,
  entidad character varying(60) NOT NULL DEFAULT ''::character varying,
  tipo_cuenta character varying(15) NOT NULL DEFAULT ''::character varying,
  numero_cuenta character varying(20) NOT NULL DEFAULT ''::character varying,
  valor_comprar numeric(15,2) NOT NULL DEFAULT 0.0,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(50) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(50) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_soc_sol_aval FOREIGN KEY (numero_solicitud)
      REFERENCES solicitud_aval (numero_solicitud) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE solicitud_obligaciones_comprar
  OWNER TO postgres;
GRANT ALL ON TABLE solicitud_obligaciones_comprar TO postgres;
GRANT SELECT ON TABLE solicitud_obligaciones_comprar TO msoto;

