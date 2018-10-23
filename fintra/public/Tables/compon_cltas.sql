-- Table: compon_cltas

-- DROP TABLE compon_cltas;

CREATE TABLE compon_cltas
(
  id_consulta integer NOT NULL,
  tipo_componente character varying(50) NOT NULL,
  parametro character varying(50) NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_consultas_id FOREIGN KEY (id_consulta)
      REFERENCES consultas (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE compon_cltas
  OWNER TO postgres;
GRANT ALL ON TABLE compon_cltas TO postgres;
GRANT SELECT ON TABLE compon_cltas TO msoto;
COMMENT ON TABLE compon_cltas
  IS 'Tabla para listar un componente html en el modulo de webviews';

