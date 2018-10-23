-- Table: administrativo.asociacion_cartera

-- DROP TABLE administrativo.asociacion_cartera;

CREATE TABLE administrativo.asociacion_cartera
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(6) NOT NULL DEFAULT 'FINV'::character varying,
  codigo character varying(20) NOT NULL DEFAULT ''::character varying,
  nombre character varying(30) NOT NULL DEFAULT ''::character varying,
  cuenta character varying(25) NOT NULL DEFAULT ''::character varying,
  cmc character varying(6) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(200) NOT NULL DEFAULT ''::character varying,
  referencia_1 character varying(25) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(15) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.asociacion_cartera
  OWNER TO postgres;

