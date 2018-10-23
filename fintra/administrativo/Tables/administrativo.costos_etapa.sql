-- Table: administrativo.costos_etapa

-- DROP TABLE administrativo.costos_etapa;

CREATE TABLE administrativo.costos_etapa
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  id_etapa integer NOT NULL,
  concepto character varying(100) NOT NULL,
  tipo character varying(1) NOT NULL DEFAULT 'M'::character varying,
  valor numeric(12,2) NOT NULL,
  solo_automotor character varying(1) NOT NULL DEFAULT ''::character varying,
  estado_approv character varying(10) NOT NULL DEFAULT 'P'::character varying,
  usuario_approv character varying(20) NOT NULL DEFAULT ''::character varying,
  fecha_approv timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT costos_etapa_id_etapa_fkey FOREIGN KEY (id_etapa)
      REFERENCES administrativo.etapas_proc_ejecutivo (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.costos_etapa
  OWNER TO postgres;

-- Trigger: h_costos_etapa on administrativo.costos_etapa

-- DROP TRIGGER h_costos_etapa ON administrativo.costos_etapa;

CREATE TRIGGER h_costos_etapa
  AFTER INSERT OR UPDATE
  ON administrativo.costos_etapa
  FOR EACH ROW
  EXECUTE PROCEDURE administrativo.insert_h_costos_etapa();


