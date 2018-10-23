-- Table: administrativo.cargos

-- DROP TABLE administrativo.cargos;

CREATE TABLE administrativo.cargos
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  descripcion character varying(200),
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(10) DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  codigo character varying(16) DEFAULT ''::character varying,
  procesado_apot character varying(1) DEFAULT 'N'::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.cargos
  OWNER TO postgres;

