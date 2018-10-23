-- Table: wsdc.infoagremc_rs_imagentendenciaendeudamiento

-- DROP TABLE wsdc.infoagremc_rs_imagentendenciaendeudamiento;

CREATE TABLE wsdc.infoagremc_rs_imagentendenciaendeudamiento
(
  id serial NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  tipo_identificacion smallint NOT NULL,
  identificacion character varying NOT NULL,
  nit_empresa character varying NOT NULL DEFAULT ''::character varying,
  serie character varying NOT NULL DEFAULT ''::character varying,
  valor character varying NOT NULL DEFAULT ''::character varying,
  fecha character varying NOT NULL DEFAULT ''::character varying,
  creation_user character varying NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT now()
)
WITH (
  OIDS=FALSE
);
ALTER TABLE wsdc.infoagremc_rs_imagentendenciaendeudamiento
  OWNER TO postgres;

