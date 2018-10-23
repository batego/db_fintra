-- Table: extractos_generados_hcg

-- DROP TABLE extractos_generados_hcg;

CREATE TABLE extractos_generados_hcg
(
  id integer,
  unidad_negocio numeric,
  cod_neg character varying,
  nit character varying,
  periodo character varying,
  generado character varying(1),
  creation_date timestamp without time zone,
  creation_user character varying,
  num_ciclo integer,
  dstrct character varying(4)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE extractos_generados_hcg
  OWNER TO postgres;
GRANT ALL ON TABLE extractos_generados_hcg TO postgres;
GRANT SELECT ON TABLE extractos_generados_hcg TO msoto;

