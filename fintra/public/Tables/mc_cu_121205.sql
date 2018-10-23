-- Table: mc_cu_121205

-- DROP TABLE mc_cu_121205;

CREATE TABLE mc_cu_121205
(
  reg_status character varying(1),
  dstrct character varying(6),
  numero_solicitud integer,
  consecutivo integer,
  tipo character varying(15),
  banco character varying(60),
  cuenta character varying(20),
  fecha_apertura timestamp without time zone,
  numero_tarjeta character varying(20),
  creation_date timestamp without time zone,
  creation_user character varying(50),
  last_update timestamp without time zone,
  user_update character varying(50)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE mc_cu_121205
  OWNER TO postgres;

