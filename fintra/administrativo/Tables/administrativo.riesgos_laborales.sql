-- Table: administrativo.riesgos_laborales

-- DROP TABLE administrativo.riesgos_laborales;

CREATE TABLE administrativo.riesgos_laborales
(
  id integer NOT NULL DEFAULT nextval('administrativo.arl_id_seq'::regclass),
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  descripcion character varying(200),
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(10) DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  nit character varying(15),
  digito_verificacion character varying(1)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.riesgos_laborales
  OWNER TO postgres;

