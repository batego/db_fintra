-- Table: mc_sd_121205

-- DROP TABLE mc_sd_121205;

CREATE TABLE mc_sd_121205
(
  reg_status character varying(1),
  dstrct character varying(6),
  numero_solicitud integer,
  num_titulo character varying(15),
  valor numeric(15,2),
  fecha timestamp without time zone,
  liquidacion numeric,
  creation_date timestamp without time zone,
  creation_user character varying(50),
  last_update timestamp without time zone,
  user_update character varying(50),
  comision_aval numeric,
  est_indemnizacion character varying(3),
  devuelto integer
)
WITH (
  OIDS=FALSE
);
ALTER TABLE mc_sd_121205
  OWNER TO postgres;

