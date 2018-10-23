-- Table: wsdc.infoagr_rs_saldos

-- DROP TABLE wsdc.infoagr_rs_saldos;

CREATE TABLE wsdc.infoagr_rs_saldos
(
  id serial NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  tipo_identificacion smallint NOT NULL,
  identificacion character varying NOT NULL,
  nit_empresa character varying NOT NULL DEFAULT ''::character varying,
  saldototalenmora character varying NOT NULL DEFAULT ''::character varying,
  saldom30 character varying NOT NULL DEFAULT ''::character varying,
  saldom60 character varying NOT NULL DEFAULT ''::character varying,
  saldom90 character varying NOT NULL DEFAULT ''::character varying,
  cuotamensual character varying NOT NULL DEFAULT ''::character varying,
  saldocreditomasalto character varying NOT NULL DEFAULT ''::character varying,
  saldototal character varying NOT NULL DEFAULT ''::character varying,
  creation_user character varying NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT now()
)
WITH (
  OIDS=FALSE
);
ALTER TABLE wsdc.infoagr_rs_saldos
  OWNER TO postgres;

