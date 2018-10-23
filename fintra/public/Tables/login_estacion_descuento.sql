-- Table: login_estacion_descuento

-- DROP TABLE login_estacion_descuento;

CREATE TABLE login_estacion_descuento
(
  loginx character varying(10) NOT NULL DEFAULT ''::character varying,
  tasa_descuento numeric(5,2) NOT NULL DEFAULT 0,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE login_estacion_descuento
  OWNER TO postgres;
GRANT ALL ON TABLE login_estacion_descuento TO postgres;
GRANT SELECT ON TABLE login_estacion_descuento TO blackberry;
GRANT SELECT ON TABLE login_estacion_descuento TO msoto;

