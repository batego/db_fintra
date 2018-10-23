-- Table: con.mc_config_nombre_tabla

-- DROP TABLE con.mc_config_nombre_tabla;

CREATE TABLE con.mc_config_nombre_tabla
(
  operacion character varying NOT NULL,
  tabla character varying,
  base_datos character varying,
  empresa character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.mc_config_nombre_tabla
  OWNER TO postgres;

