-- Table: administrativo.rel_costos_neg_etapa

-- DROP TABLE administrativo.rel_costos_neg_etapa;

CREATE TABLE administrativo.rel_costos_neg_etapa
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  id_etapa integer NOT NULL,
  negocio character varying(15) NOT NULL,
  id_costo integer NOT NULL,
  valor numeric(12,2) NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT rel_costos_neg_etapa_id_costo_fkey FOREIGN KEY (id_costo)
      REFERENCES administrativo.costos_etapa (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT rel_costos_neg_etapa_id_etapa_fkey FOREIGN KEY (id_etapa)
      REFERENCES administrativo.etapas_proc_ejecutivo (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT rel_costos_neg_etapa_negocio_fkey FOREIGN KEY (negocio)
      REFERENCES negocios (cod_neg) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.rel_costos_neg_etapa
  OWNER TO postgres;

-- Trigger: h_rel_costos_neg_etapa on administrativo.rel_costos_neg_etapa

-- DROP TRIGGER h_rel_costos_neg_etapa ON administrativo.rel_costos_neg_etapa;

CREATE TRIGGER h_rel_costos_neg_etapa
  AFTER INSERT OR UPDATE OR DELETE
  ON administrativo.rel_costos_neg_etapa
  FOR EACH ROW
  EXECUTE PROCEDURE administrativo.insert_h_rel_costos_neg_etapa();


