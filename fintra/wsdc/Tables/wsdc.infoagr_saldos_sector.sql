-- Table: wsdc.infoagr_saldos_sector

-- DROP TABLE wsdc.infoagr_saldos_sector;

CREATE TABLE wsdc.infoagr_saldos_sector
(
  id serial NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  tipo_identificacion smallint NOT NULL,
  identificacion character varying NOT NULL,
  nit_empresa character varying NOT NULL DEFAULT ''::character varying,
  sector character varying NOT NULL DEFAULT ''::character varying,
  saldo character varying NOT NULL DEFAULT ''::character varying,
  participacion character varying NOT NULL DEFAULT ''::character varying,
  creation_user character varying NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT now()
)
WITH (
  OIDS=FALSE
);
ALTER TABLE wsdc.infoagr_saldos_sector
  OWNER TO postgres;

