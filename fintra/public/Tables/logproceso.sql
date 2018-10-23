-- Table: logproceso

-- DROP TABLE logproceso;

CREATE TABLE logproceso
(
  fecha_inicial timestamp with time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  proceso character varying(100) NOT NULL DEFAULT ''::character varying,
  id numeric NOT NULL,
  descripcion text NOT NULL,
  usuario character varying(20) NOT NULL DEFAULT ''::character varying,
  estado character varying(11) DEFAULT ''::character varying,
  fecha_final timestamp with time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  duracion character varying(30) NOT NULL DEFAULT 0,
  estado_finalizado text NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE logproceso
  OWNER TO postgres;
GRANT ALL ON TABLE logproceso TO postgres;
GRANT SELECT ON TABLE logproceso TO msoto;

