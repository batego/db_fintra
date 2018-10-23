-- Table: wsdc.infoagremc_rs_vectorsaldosymoras

-- DROP TABLE wsdc.infoagremc_rs_vectorsaldosymoras;

CREATE TABLE wsdc.infoagremc_rs_vectorsaldosymoras
(
  id serial NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  tipo_identificacion smallint NOT NULL,
  identificacion character varying NOT NULL,
  nit_empresa character varying NOT NULL DEFAULT ''::character varying,
  poseesectorcooperativo character varying NOT NULL DEFAULT ''::character varying,
  poseesectorfinanciero character varying NOT NULL DEFAULT ''::character varying,
  poseesectorreal character varying NOT NULL DEFAULT ''::character varying,
  poseesectortelcos character varying NOT NULL DEFAULT ''::character varying,
  fecha character varying NOT NULL DEFAULT ''::character varying,
  totalcuentasmora character varying NOT NULL DEFAULT ''::character varying,
  saldodeudatotalmora character varying NOT NULL DEFAULT ''::character varying,
  saldodeudatotal character varying NOT NULL DEFAULT ''::character varying,
  morasmaxsectorfinanciero character varying NOT NULL DEFAULT ''::character varying,
  morasmaxsectorreal character varying NOT NULL DEFAULT ''::character varying,
  morasmaxsectortelcos character varying NOT NULL DEFAULT ''::character varying,
  morasmaximas character varying NOT NULL DEFAULT ''::character varying,
  numcreditos30 character varying NOT NULL DEFAULT ''::character varying,
  numcreditosmayorigual60 character varying NOT NULL DEFAULT ''::character varying,
  creation_user character varying NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT now()
)
WITH (
  OIDS=FALSE
);
ALTER TABLE wsdc.infoagremc_rs_vectorsaldosymoras
  OWNER TO postgres;

