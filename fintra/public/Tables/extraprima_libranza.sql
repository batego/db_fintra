-- Table: extraprima_libranza

-- DROP TABLE extraprima_libranza;

CREATE TABLE extraprima_libranza
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  id_ocupacion_laboral integer,
  descripcion character varying(200),
  edad_inicial numeric(9,2),
  edad_final numeric(9,2),
  perc_extraprima numeric(11,2),
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(10),
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_extraprima_ocuplaboral_id FOREIGN KEY (id_ocupacion_laboral)
      REFERENCES ocupacion_laboral (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE extraprima_libranza
  OWNER TO postgres;
GRANT ALL ON TABLE extraprima_libranza TO postgres;
GRANT SELECT ON TABLE extraprima_libranza TO msoto;

