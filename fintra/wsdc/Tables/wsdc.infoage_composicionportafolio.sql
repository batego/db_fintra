-- Table: wsdc.infoage_composicionportafolio

-- DROP TABLE wsdc.infoage_composicionportafolio;

CREATE TABLE wsdc.infoage_composicionportafolio
(
  id serial NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  tipo_identificacion smallint NOT NULL,
  identificacion character varying NOT NULL,
  nit_empresa character varying NOT NULL DEFAULT ''::character varying,
  tipo character varying NOT NULL DEFAULT ''::character varying,
  calidaddeudor character varying NOT NULL DEFAULT ''::character varying,
  porcentaje character varying NOT NULL DEFAULT ''::character varying,
  cantidad_tipocuenta character varying NOT NULL DEFAULT ''::character varying,
  codigo character varying NOT NULL DEFAULT ''::character varying,
  cantidad_estado character varying NOT NULL DEFAULT ''::character varying,
  creation_user character varying NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT now()
)
WITH (
  OIDS=FALSE
);
ALTER TABLE wsdc.infoage_composicionportafolio
  OWNER TO postgres;

