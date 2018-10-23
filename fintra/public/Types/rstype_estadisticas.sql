-- Type: rstype_estadisticas

-- DROP TYPE rstype_estadisticas;

CREATE TYPE rstype_estadisticas AS
   (secuencia_i integer,
    enero character varying,
    febrero character varying,
    marzo character varying,
    abril character varying,
    mayo character varying,
    junio character varying,
    julio character varying,
    agosto character varying,
    septiembre character varying,
    octubre character varying,
    noviembre character varying,
    diciembre character varying,
    acumulado character varying);
ALTER TYPE rstype_estadisticas
  OWNER TO postgres;
