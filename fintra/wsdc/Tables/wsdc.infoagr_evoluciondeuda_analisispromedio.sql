-- Table: wsdc.infoagr_evoluciondeuda_analisispromedio

-- DROP TABLE wsdc.infoagr_evoluciondeuda_analisispromedio;

CREATE TABLE wsdc.infoagr_evoluciondeuda_analisispromedio
(
  id serial NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  tipo_identificacion smallint NOT NULL,
  identificacion character varying NOT NULL,
  nit_empresa character varying NOT NULL DEFAULT ''::character varying,
  cuota character varying NOT NULL DEFAULT ''::character varying,
  cupototal character varying NOT NULL DEFAULT ''::character varying,
  saldo character varying NOT NULL DEFAULT ''::character varying,
  porcentajeuso character varying NOT NULL DEFAULT ''::character varying,
  score character varying NOT NULL DEFAULT ''::character varying,
  calificacion character varying NOT NULL DEFAULT ''::character varying,
  aperturacuentas character varying NOT NULL DEFAULT ''::character varying,
  cierrecuentas character varying NOT NULL DEFAULT ''::character varying,
  totalabiertas character varying NOT NULL DEFAULT ''::character varying,
  totalcerradas character varying NOT NULL DEFAULT ''::character varying,
  moramaxima character varying NOT NULL DEFAULT ''::character varying,
  creation_user character varying NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT now()
)
WITH (
  OIDS=FALSE
);
ALTER TABLE wsdc.infoagr_evoluciondeuda_analisispromedio
  OWNER TO postgres;

