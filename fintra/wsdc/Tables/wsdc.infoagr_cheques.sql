-- Table: wsdc.infoagr_cheques

-- DROP TABLE wsdc.infoagr_cheques;

CREATE TABLE wsdc.infoagr_cheques
(
  id serial NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  tipo_identificacion smallint NOT NULL,
  identificacion character varying NOT NULL,
  nit_empresa character varying NOT NULL DEFAULT ''::character varying,
  fecha character varying NOT NULL DEFAULT ''::character varying,
  cantidaddevueltos character varying NOT NULL DEFAULT ''::character varying,
  valordevueltos character varying NOT NULL DEFAULT ''::character varying,
  cantidadpagados character varying NOT NULL DEFAULT ''::character varying,
  valorpagados character varying NOT NULL DEFAULT ''::character varying,
  creation_user character varying NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT now()
)
WITH (
  OIDS=FALSE
);
ALTER TABLE wsdc.infoagr_cheques
  OWNER TO postgres;

