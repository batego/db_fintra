-- Table: ocupacion_laboral

-- DROP TABLE ocupacion_laboral;

CREATE TABLE ocupacion_laboral
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  descripcion character varying(200),
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(10),
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE ocupacion_laboral
  OWNER TO postgres;
GRANT ALL ON TABLE ocupacion_laboral TO postgres;
GRANT SELECT ON TABLE ocupacion_laboral TO msoto;

