-- Table: comisiones_bancos

-- DROP TABLE comisiones_bancos;

CREATE TABLE comisiones_bancos
(
  id serial NOT NULL,
  reg_status character varying(2),
  dstrct character varying(4),
  anio character varying(4) NOT NULL,
  banco_transfer character varying(30) NOT NULL,
  valor numeric(10,2),
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  user_update character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  valor_1 numeric(10,2)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE comisiones_bancos
  OWNER TO postgres;
GRANT ALL ON TABLE comisiones_bancos TO postgres;
GRANT SELECT ON TABLE comisiones_bancos TO msoto;

