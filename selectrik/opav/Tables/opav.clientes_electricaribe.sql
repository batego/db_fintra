-- Table: opav.clientes_electricaribe

-- DROP TABLE opav.clientes_electricaribe;

CREATE TABLE opav.clientes_electricaribe
(
  nic numeric NOT NULL,
  titular character varying(100) NOT NULL DEFAULT ''::character varying,
  direccion character varying(100) NOT NULL DEFAULT ''::character varying,
  telefono character varying(50) NOT NULL DEFAULT ''::character varying,
  estrato integer NOT NULL DEFAULT 0,
  calificacion integer NOT NULL DEFAULT 0,
  barrio character varying(50) NOT NULL DEFAULT ''::character varying,
  municipio character varying(50) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.clientes_electricaribe
  OWNER TO postgres;
