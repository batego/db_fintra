-- Table: mc_sh_121205

-- DROP TABLE mc_sh_121205;

CREATE TABLE mc_sh_121205
(
  reg_status character varying(1),
  dstrct character varying(6),
  numero_solicitud integer,
  tipo character varying(1),
  secuencia integer,
  nombre character varying(100),
  direccion character varying(60),
  telefono character varying(15),
  edad integer,
  email character varying(100),
  creation_date timestamp without time zone,
  creation_user character varying(50),
  last_update timestamp without time zone,
  user_update character varying(50)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE mc_sh_121205
  OWNER TO postgres;

