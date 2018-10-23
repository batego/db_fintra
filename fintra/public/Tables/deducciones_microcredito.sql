-- Table: deducciones_microcredito

-- DROP TABLE deducciones_microcredito;

CREATE TABLE deducciones_microcredito
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  id_ocupacion_laboral integer,
  id_operacion_libranza integer,
  descripcion character varying(200),
  desembolso_inicial numeric(11,2),
  desembolso_final numeric(11,2),
  valor_cobrar numeric(11,2) NOT NULL DEFAULT 0,
  perc_cobrar numeric(11,2) NOT NULL DEFAULT 0,
  n_xmil numeric(11,2) NOT NULL DEFAULT 0,
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(10),
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_dl_ocupacion_laboral_id FOREIGN KEY (id_ocupacion_laboral)
      REFERENCES ocupacion_laboral (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_dl_operacion_libranza_id FOREIGN KEY (id_operacion_libranza)
      REFERENCES operaciones_libranza (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE deducciones_microcredito
  OWNER TO postgres;
GRANT ALL ON TABLE deducciones_microcredito TO postgres;
GRANT SELECT ON TABLE deducciones_microcredito TO msoto;

