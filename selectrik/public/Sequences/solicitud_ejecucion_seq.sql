-- Sequence: solicitud_ejecucion_seq

-- DROP SEQUENCE solicitud_ejecucion_seq;

CREATE SEQUENCE solicitud_ejecucion_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 82
  CACHE 1;
ALTER TABLE solicitud_ejecucion_seq
  OWNER TO postgres;
