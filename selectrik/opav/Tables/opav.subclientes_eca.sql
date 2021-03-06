-- Table: opav.subclientes_eca

-- DROP TABLE opav.subclientes_eca;

CREATE TABLE opav.subclientes_eca
(
  id_subcliente character varying(10) NOT NULL DEFAULT ''::character varying,
  id_cliente_padre character varying(10) DEFAULT ''::character varying,
  user_update character varying(10) DEFAULT ''::character varying,
  creation_user character varying(10) DEFAULT ''::character varying,
  last_update timestamp without time zone DEFAULT now(),
  creation_date timestamp without time zone DEFAULT now(),
  reg_status character varying(1) DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.subclientes_eca
  OWNER TO postgres;
