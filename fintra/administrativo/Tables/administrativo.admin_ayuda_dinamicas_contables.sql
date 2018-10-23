-- Table: administrativo.admin_ayuda_dinamicas_contables

-- DROP TABLE administrativo.admin_ayuda_dinamicas_contables;

CREATE TABLE administrativo.admin_ayuda_dinamicas_contables
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT 'FINV'::character varying,
  modulo character varying(30) NOT NULL DEFAULT ''::character varying,
  descripcion_modulo character varying(30) NOT NULL DEFAULT ''::character varying,
  paso character varying(6) NOT NULL DEFAULT ''::character varying,
  descripcion_ayuda text NOT NULL DEFAULT ''::text,
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.admin_ayuda_dinamicas_contables
  OWNER TO postgres;

