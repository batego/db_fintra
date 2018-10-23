-- Table: convenciones

-- DROP TABLE convenciones;

CREATE TABLE convenciones
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  tipo character varying NOT NULL DEFAULT ''::character varying,
  valor_cuestionado character varying NOT NULL DEFAULT ''::character varying,
  convencion character varying NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT 'HCUELLO'::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE convenciones
  OWNER TO postgres;
GRANT ALL ON TABLE convenciones TO postgres;
GRANT SELECT ON TABLE convenciones TO msoto;

