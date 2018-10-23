-- Table: administrativo.demanda

-- DROP TABLE administrativo.demanda;

CREATE TABLE administrativo.demanda
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  id_etapa integer NOT NULL,
  negocio character varying(15) NOT NULL,
  nitdemandado character varying(15) NOT NULL,
  estado_proceso integer NOT NULL,
  docs_generados character varying(1) NOT NULL DEFAULT 'N'::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  id_juzgado integer,
  radicado character varying(20) DEFAULT ''::character varying,
  CONSTRAINT demanda_negocio_fkey FOREIGN KEY (negocio)
      REFERENCES negocios (cod_neg) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.demanda
  OWNER TO postgres;

