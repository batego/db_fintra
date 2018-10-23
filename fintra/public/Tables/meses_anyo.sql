-- Table: "meses_año"

-- DROP TABLE "meses_año";

CREATE TABLE "meses_año"
(
  id integer NOT NULL,
  descripcion character varying(20) NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE "meses_año"
  OWNER TO postgres;
GRANT ALL ON TABLE "meses_año" TO postgres;
GRANT SELECT ON TABLE "meses_año" TO msoto;

