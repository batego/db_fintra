-- Table: administrativo.entidades_compra_cartera

-- DROP TABLE administrativo.entidades_compra_cartera;

CREATE TABLE administrativo.entidades_compra_cartera
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  nombre_entidad character varying(300) NOT NULL DEFAULT ''::character varying,
  nit_entidad character varying(15) NOT NULL DEFAULT ''::character varying,
  digito_nit character varying(1) NOT NULL DEFAULT ''::character varying,
  codigo_entidad character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.entidades_compra_cartera
  OWNER TO postgres;

