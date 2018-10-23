-- Table: wsdc.infoagremc_evoluciondeuda

-- DROP TABLE wsdc.infoagremc_evoluciondeuda;

CREATE TABLE wsdc.infoagremc_evoluciondeuda
(
  id serial NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  tipo_identificacion smallint NOT NULL,
  identificacion character varying NOT NULL,
  nit_empresa character varying NOT NULL DEFAULT ''::character varying,
  codsector character varying NOT NULL DEFAULT ''::character varying,
  nombresector character varying NOT NULL DEFAULT ''::character varying,
  tipocuenta character varying NOT NULL DEFAULT ''::character varying,
  trimestre character varying NOT NULL DEFAULT ''::character varying,
  num character varying NOT NULL DEFAULT ''::character varying,
  cupoinicial character varying NOT NULL DEFAULT ''::character varying,
  saldo character varying NOT NULL DEFAULT ''::character varying,
  saldomora character varying NOT NULL DEFAULT ''::character varying,
  cuota character varying NOT NULL DEFAULT ''::character varying,
  porcentajedeuda character varying NOT NULL DEFAULT ''::character varying,
  codmenorcalificacion character varying NOT NULL DEFAULT ''::character varying,
  textomenorcalificacion character varying NOT NULL DEFAULT ''::character varying,
  creation_user character varying NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT now()
)
WITH (
  OIDS=FALSE
);
ALTER TABLE wsdc.infoagremc_evoluciondeuda
  OWNER TO postgres;

