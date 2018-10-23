-- Table: estado_civil

-- DROP TABLE estado_civil;

CREATE TABLE estado_civil
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  cod character varying(1) NOT NULL,
  descripcion character varying(200),
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(10),
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE estado_civil
  OWNER TO postgres;
GRANT ALL ON TABLE estado_civil TO postgres;
GRANT SELECT ON TABLE estado_civil TO msoto;

