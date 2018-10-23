-- Table: sms_educativos

-- DROP TABLE sms_educativos;

CREATE TABLE sms_educativos
(
  id serial NOT NULL,
  nombre character varying(150) NOT NULL,
  celular character varying(10) NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE sms_educativos
  OWNER TO postgres;
GRANT ALL ON TABLE sms_educativos TO postgres;
GRANT SELECT ON TABLE sms_educativos TO msoto;

