-- Table: administrativo.juzgados

-- DROP TABLE administrativo.juzgados;

CREATE TABLE administrativo.juzgados
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT 'FINV'::character varying,
  nombre character varying(150) NOT NULL,
  codciu character varying(6) NOT NULL DEFAULT ''::character varying,
  coddpto character varying(3) NOT NULL DEFAULT ''::character varying,
  codpais character varying(3) NOT NULL DEFAULT ''::character varying,
  direccion character varying(160) NOT NULL DEFAULT ''::character varying,
  barrio character varying(100) NOT NULL DEFAULT ''::character varying,
  nombre_juez character varying(160) NOT NULL DEFAULT ''::character varying,
  secretario character varying(160) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.juzgados
  OWNER TO postgres;

