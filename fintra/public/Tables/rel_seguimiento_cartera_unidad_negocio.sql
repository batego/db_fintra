-- Table: rel_seguimiento_cartera_unidad_negocio

-- DROP TABLE rel_seguimiento_cartera_unidad_negocio;

CREATE TABLE rel_seguimiento_cartera_unidad_negocio
(
  id serial NOT NULL,
  id_unidad_negocio integer,
  id_usuario character varying(10)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE rel_seguimiento_cartera_unidad_negocio
  OWNER TO postgres;

