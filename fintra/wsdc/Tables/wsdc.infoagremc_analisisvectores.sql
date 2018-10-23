-- Table: wsdc.infoagremc_analisisvectores

-- DROP TABLE wsdc.infoagremc_analisisvectores;

CREATE TABLE wsdc.infoagremc_analisisvectores
(
  id serial NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  tipo_identificacion smallint NOT NULL,
  identificacion character varying NOT NULL,
  nit_empresa character varying NOT NULL DEFAULT ''::character varying,
  nombresector character varying NOT NULL DEFAULT ''::character varying,
  entidad character varying NOT NULL DEFAULT ''::character varying,
  numerocuenta character varying NOT NULL DEFAULT ''::character varying,
  tipocuenta character varying NOT NULL DEFAULT ''::character varying,
  estado character varying NOT NULL DEFAULT ''::character varying,
  contienedatos character varying NOT NULL DEFAULT ''::character varying,
  fecha character varying NOT NULL DEFAULT ''::character varying,
  saldodeudatotalmora character varying NOT NULL DEFAULT ''::character varying,
  creation_user character varying NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  etiqueta character varying(50)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE wsdc.infoagremc_analisisvectores
  OWNER TO postgres;

