-- Table: cr_negocios_errores

-- DROP TABLE cr_negocios_errores;

CREATE TABLE cr_negocios_errores
(
  id serial NOT NULL,
  negocio character varying(20) NOT NULL DEFAULT ''::character varying,
  identificacion character varying(40),
  periodo_lote character varying(6),
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cr_negocios_errores
  OWNER TO postgres;
GRANT ALL ON TABLE cr_negocios_errores TO postgres;
GRANT SELECT ON TABLE cr_negocios_errores TO msoto;

