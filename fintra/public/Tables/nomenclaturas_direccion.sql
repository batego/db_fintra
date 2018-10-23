-- Table: nomenclaturas_direccion

-- DROP TABLE nomenclaturas_direccion;

CREATE TABLE nomenclaturas_direccion
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  id_nomenclatura integer NOT NULL,
  ciudad character varying(6) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE nomenclaturas_direccion
  OWNER TO postgres;
GRANT ALL ON TABLE nomenclaturas_direccion TO postgres;
GRANT SELECT ON TABLE nomenclaturas_direccion TO msoto;

