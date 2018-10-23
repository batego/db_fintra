-- Table: constante

-- DROP TABLE constante;

CREATE TABLE constante
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  codigo character varying(50) NOT NULL DEFAULT ''::character varying,
  descripcion text NOT NULL DEFAULT ''::character varying,
  valor text NOT NULL DEFAULT ''::text,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE constante
  OWNER TO postgres;
GRANT ALL ON TABLE constante TO postgres;
GRANT SELECT ON TABLE constante TO msoto;

