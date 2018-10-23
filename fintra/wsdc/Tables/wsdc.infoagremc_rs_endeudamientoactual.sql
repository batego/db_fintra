-- Table: wsdc.infoagremc_rs_endeudamientoactual

-- DROP TABLE wsdc.infoagremc_rs_endeudamientoactual;

CREATE TABLE wsdc.infoagremc_rs_endeudamientoactual
(
  id serial NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  tipo_identificacion smallint NOT NULL,
  identificacion character varying NOT NULL,
  nit_empresa character varying NOT NULL DEFAULT ''::character varying,
  codsector character varying NOT NULL DEFAULT ''::character varying,
  tipocuenta character varying NOT NULL DEFAULT ''::character varying,
  tipousuario character varying NOT NULL DEFAULT ''::character varying,
  estadoactual character varying NOT NULL DEFAULT ''::character varying,
  calificacion character varying NOT NULL DEFAULT ''::character varying,
  valorinicial character varying NOT NULL DEFAULT ''::character varying,
  saldoactual character varying NOT NULL DEFAULT ''::character varying,
  saldomora character varying NOT NULL DEFAULT ''::character varying,
  cuotames character varying NOT NULL DEFAULT ''::character varying,
  comportamientonegativo character varying NOT NULL DEFAULT ''::character varying,
  totaldeudacarteras character varying NOT NULL DEFAULT ''::character varying,
  creation_user character varying NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT now()
)
WITH (
  OIDS=FALSE
);
ALTER TABLE wsdc.infoagremc_rs_endeudamientoactual
  OWNER TO postgres;

