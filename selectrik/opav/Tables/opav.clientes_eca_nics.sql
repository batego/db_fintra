-- Table: opav.clientes_eca_nics

-- DROP TABLE opav.clientes_eca_nics;

CREATE TABLE opav.clientes_eca_nics
(
  nic character varying(10) NOT NULL DEFAULT ''::character varying,
  id_cliente character varying(10) NOT NULL DEFAULT ''::character varying,
  reg_status character varying(1) DEFAULT ''::character varying,
  creation_user character varying(10) DEFAULT ''::character varying,
  user_update character varying(10) DEFAULT ''::character varying,
  creation_date timestamp without time zone DEFAULT now(),
  last_update timestamp without time zone DEFAULT now(),
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.clientes_eca_nics
  OWNER TO postgres;
GRANT ALL ON TABLE opav.clientes_eca_nics TO postgres;
