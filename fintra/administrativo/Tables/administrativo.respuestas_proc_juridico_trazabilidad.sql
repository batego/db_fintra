-- Table: administrativo.respuestas_proc_juridico_trazabilidad

-- DROP TABLE administrativo.respuestas_proc_juridico_trazabilidad;

CREATE TABLE administrativo.respuestas_proc_juridico_trazabilidad
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  id_etapa integer NOT NULL,
  negocio character varying(15) NOT NULL,
  id_respuesta integer NOT NULL,
  respuesta character varying(50) NOT NULL,
  comentarios text NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT respuestas_proc_juridico_trazabilidad_negocio_fkey FOREIGN KEY (negocio)
      REFERENCES negocios (cod_neg) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT respuestas_proc_juridico_trazabilidad_negocio_fkey1 FOREIGN KEY (negocio)
      REFERENCES negocios (cod_neg) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.respuestas_proc_juridico_trazabilidad
  OWNER TO postgres;

