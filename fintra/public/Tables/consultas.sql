-- Table: consultas

-- DROP TABLE consultas;

CREATE TABLE consultas
(
  id serial NOT NULL,
  creador character varying(10) NOT NULL DEFAULT ''::character varying,
  usuario text NOT NULL DEFAULT ''::text,
  descripcion text NOT NULL DEFAULT ''::text,
  query text NOT NULL DEFAULT ''::text, -- Cadena donde se almacena la consulta SQL. Puede parametrizarse utilizando una etiqueta especial para este proposito (<param>). NOTA: Si la consulta es parametrizada, es OBLIGATORIO definir la descripcion de (los) parametro(s).
  nombresparams text NOT NULL DEFAULT ''::text,
  fechacreacion timestamp without time zone NOT NULL DEFAULT now(),
  basededatos character varying(10) NOT NULL DEFAULT 'PSQL_SOT'::character varying, -- Base de datos en la cual se ejecuta este query. Solo tiene 2 valores posibles: PSQL_SOT (PostgreSQL - sot) y ORA_MIMS (Oracle - pdrmoe43)
  estado character(1) NOT NULL DEFAULT 'A'::bpchar, -- ESTADO DE LA CONSULTA 'A' ACTIVO 'I' INACTIVO
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE consultas
  OWNER TO postgres;
GRANT ALL ON TABLE consultas TO postgres;
GRANT SELECT ON TABLE consultas TO msoto;
COMMENT ON TABLE consultas
  IS 'Esta tabla sirve para almacenar consultas y asociarlas a un usuario para generar reportes.';
COMMENT ON COLUMN consultas.query IS 'Cadena donde se almacena la consulta SQL. Puede parametrizarse utilizando una etiqueta especial para este proposito (<param>). NOTA: Si la consulta es parametrizada, es OBLIGATORIO definir la descripcion de (los) parametro(s). ';
COMMENT ON COLUMN consultas.basededatos IS 'Base de datos en la cual se ejecuta este query. Solo tiene 2 valores posibles: PSQL_SOT (PostgreSQL - sot) y ORA_MIMS (Oracle - pdrmoe43)';
COMMENT ON COLUMN consultas.estado IS 'ESTADO DE LA CONSULTA ''A'' ACTIVO ''I'' INACTIVO';


