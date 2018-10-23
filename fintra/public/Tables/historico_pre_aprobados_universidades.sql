-- Table: historico_pre_aprobados_universidades

-- DROP TABLE historico_pre_aprobados_universidades;

CREATE TABLE historico_pre_aprobados_universidades
(
  idhistorial serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  id_und_negocio integer NOT NULL,
  periodo_lote character varying(6) NOT NULL,
  nit character varying(20) NOT NULL,
  negocio character varying(15) NOT NULL,
  valor_ultimo_credito numeric(12,2) NOT NULL,
  valor_aprobado numeric(12,2) NOT NULL,
  h_comment text NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE historico_pre_aprobados_universidades
  OWNER TO postgres;
GRANT ALL ON TABLE historico_pre_aprobados_universidades TO postgres;
GRANT SELECT ON TABLE historico_pre_aprobados_universidades TO msoto;

