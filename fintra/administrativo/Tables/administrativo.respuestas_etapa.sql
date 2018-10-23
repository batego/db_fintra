-- Table: administrativo.respuestas_etapa

-- DROP TABLE administrativo.respuestas_etapa;

CREATE TABLE administrativo.respuestas_etapa
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  id_etapa integer NOT NULL,
  nombre character varying(50) NOT NULL,
  descripcion character varying(300) NOT NULL,
  dur_estimada_dias integer NOT NULL,
  secuencia integer NOT NULL,
  editar_respuesta character varying(1) NOT NULL DEFAULT ''::character varying,
  finaliza_proceso character varying(1) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT respuestas_etapa_id_etapa_fkey FOREIGN KEY (id_etapa)
      REFERENCES administrativo.etapas_proc_ejecutivo (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.respuestas_etapa
  OWNER TO postgres;

