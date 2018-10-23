-- Table: firmas_registradas

-- DROP TABLE firmas_registradas;

CREATE TABLE firmas_registradas
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  id_configuracion_libranza integer,
  nombre character varying(300) NOT NULL DEFAULT ''::character varying,
  documento character varying(15) NOT NULL DEFAULT ''::character varying,
  telefono character varying(150) NOT NULL DEFAULT ''::character varying,
  correo character varying(70) NOT NULL DEFAULT ''::character varying,
  firma_escaneada character varying(70) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_fr_configuracion_libranza_id FOREIGN KEY (id_configuracion_libranza)
      REFERENCES configuracion_libranza (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE firmas_registradas
  OWNER TO postgres;
GRANT ALL ON TABLE firmas_registradas TO postgres;
GRANT SELECT ON TABLE firmas_registradas TO msoto;

