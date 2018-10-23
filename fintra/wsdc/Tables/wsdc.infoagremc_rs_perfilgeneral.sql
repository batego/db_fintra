-- Table: wsdc.infoagremc_rs_perfilgeneral

-- DROP TABLE wsdc.infoagremc_rs_perfilgeneral;

CREATE TABLE wsdc.infoagremc_rs_perfilgeneral
(
  id serial NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  tipo_identificacion smallint NOT NULL,
  identificacion character varying NOT NULL,
  nit_empresa character varying NOT NULL DEFAULT ''::character varying,
  etiqueta character varying NOT NULL DEFAULT ''::character varying,
  sectorfinanciero character varying NOT NULL DEFAULT ''::character varying,
  sectorcooperativo character varying NOT NULL DEFAULT ''::character varying,
  sectorreal character varying NOT NULL DEFAULT ''::character varying,
  sectortelcos character varying NOT NULL DEFAULT ''::character varying,
  totalcomoprincipal character varying NOT NULL DEFAULT ''::character varying,
  totalcomocodeudoryotros character varying NOT NULL DEFAULT ''::bpchar,
  creation_user character varying NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT now()
)
WITH (
  OIDS=FALSE
);
ALTER TABLE wsdc.infoagremc_rs_perfilgeneral
  OWNER TO postgres;

