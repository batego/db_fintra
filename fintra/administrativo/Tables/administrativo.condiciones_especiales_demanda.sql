-- Table: administrativo.condiciones_especiales_demanda

-- DROP TABLE administrativo.condiciones_especiales_demanda;

CREATE TABLE administrativo.condiciones_especiales_demanda
(
  id serial NOT NULL,
  codigo character varying(10) NOT NULL,
  descripcion character varying(150) NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.condiciones_especiales_demanda
  OWNER TO postgres;

