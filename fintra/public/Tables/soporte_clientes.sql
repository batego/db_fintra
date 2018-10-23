-- Table: soporte_clientes

-- DROP TABLE soporte_clientes;

CREATE TABLE soporte_clientes
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  soporte character varying(40) NOT NULL DEFAULT ''::character varying,
  cliente character varying(40) NOT NULL DEFAULT ''::character varying,
  creation_user character varying(40) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(40) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  base character varying(3) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE soporte_clientes
  OWNER TO postgres;
GRANT ALL ON TABLE soporte_clientes TO postgres;
GRANT SELECT ON TABLE soporte_clientes TO msoto;

