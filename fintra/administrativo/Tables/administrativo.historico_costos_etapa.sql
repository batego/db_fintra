-- Table: administrativo.historico_costos_etapa

-- DROP TABLE administrativo.historico_costos_etapa;

CREATE TABLE administrativo.historico_costos_etapa
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  id_etapa integer NOT NULL,
  concepto character varying(100) NOT NULL,
  tipo character varying(1) NOT NULL DEFAULT 'M'::character varying,
  valor numeric(12,2) NOT NULL,
  solo_automotor character varying(1) NOT NULL DEFAULT ''::character varying,
  estado_approv character varying(10) NOT NULL DEFAULT ''::character varying,
  usuario_approv character varying(20) NOT NULL DEFAULT ''::character varying,
  fecha_approv timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  idhistorial serial NOT NULL,
  h_creation_date timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  h_comment text NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.historico_costos_etapa
  OWNER TO postgres;

