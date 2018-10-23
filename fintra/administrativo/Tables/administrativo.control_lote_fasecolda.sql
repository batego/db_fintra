-- Table: administrativo.control_lote_fasecolda

-- DROP TABLE administrativo.control_lote_fasecolda;

CREATE TABLE administrativo.control_lote_fasecolda
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  lote_carga character varying(10) NOT NULL DEFAULT ''::character varying,
  nombre_archivo character varying(50) NOT NULL DEFAULT ''::character varying,
  fecha_subida timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  estado character varying(20) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(20) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(20) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.control_lote_fasecolda
  OWNER TO postgres;

