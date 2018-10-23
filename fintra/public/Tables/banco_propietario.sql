-- Table: banco_propietario

-- DROP TABLE banco_propietario;

CREATE TABLE banco_propietario
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  propietario character varying(15) NOT NULL DEFAULT ''::character varying,
  hc character varying(3) NOT NULL DEFAULT ''::character varying,
  banco character varying(30) NOT NULL DEFAULT ''::character varying,
  sucursal character varying(30) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE banco_propietario
  OWNER TO postgres;
GRANT ALL ON TABLE banco_propietario TO postgres;
GRANT SELECT ON TABLE banco_propietario TO msoto;

