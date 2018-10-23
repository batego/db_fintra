-- Table: mc_sn_121205

-- DROP TABLE mc_sn_121205;

CREATE TABLE mc_sn_121205
(
  reg_status character varying(1),
  dstrct character varying(6),
  numero_solicitud integer,
  cod_sector character varying,
  cod_subsector character varying,
  nombre character varying(100),
  direccion character varying(160),
  departamento character varying(10),
  ciudad character varying(30),
  barrio character varying(100),
  telefono character varying(15),
  tiempo_local integer,
  num_exp_negocio integer,
  tiempo_microempresario integer,
  num_trabajadores integer,
  creation_date timestamp without time zone,
  creation_user character varying(50),
  last_update timestamp without time zone,
  user_update character varying(50),
  lat character varying(80),
  lng character varying(80)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE mc_sn_121205
  OWNER TO postgres;

