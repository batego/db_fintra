-- Table: administrativo.h_rel_costos_neg_etapa

-- DROP TABLE administrativo.h_rel_costos_neg_etapa;

CREATE TABLE administrativo.h_rel_costos_neg_etapa
(
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
  idhistorial serial NOT NULL,
  h_creation_date timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  h_comment text
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.h_rel_costos_neg_etapa
  OWNER TO postgres;

