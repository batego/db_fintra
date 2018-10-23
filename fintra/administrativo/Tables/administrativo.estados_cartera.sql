-- Table: administrativo.estados_cartera

-- DROP TABLE administrativo.estados_cartera;

CREATE TABLE administrativo.estados_cartera
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  nombre character varying(20) NOT NULL,
  descripcion character varying(300) NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.estados_cartera
  OWNER TO postgres;

