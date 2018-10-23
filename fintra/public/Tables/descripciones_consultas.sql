-- Table: descripciones_consultas

-- DROP TABLE descripciones_consultas;

CREATE TABLE descripciones_consultas
(
  id integer NOT NULL, -- consulta
  grandescripcion text NOT NULL DEFAULT ''::text, -- big description
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE descripciones_consultas
  OWNER TO postgres;
GRANT ALL ON TABLE descripciones_consultas TO postgres;
GRANT SELECT ON TABLE descripciones_consultas TO msoto;
COMMENT ON TABLE descripciones_consultas
  IS 'descripciones de las consultas que estan en la tabla consultas... web views';
COMMENT ON COLUMN descripciones_consultas.id IS 'consulta';
COMMENT ON COLUMN descripciones_consultas.grandescripcion IS 'big description';


