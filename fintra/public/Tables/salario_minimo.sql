-- Table: salario_minimo

-- DROP TABLE salario_minimo;

CREATE TABLE salario_minimo
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  ano character varying(6),
  salario_minimo_diario numeric(11,2),
  salario_minimo_mensual numeric(11,2),
  variacion_anual numeric(11,2),
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(10),
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE salario_minimo
  OWNER TO postgres;
GRANT ALL ON TABLE salario_minimo TO postgres;
GRANT SELECT ON TABLE salario_minimo TO msoto;

