-- Table: etes.rel_cxp_nota_credito

-- DROP TABLE etes.rel_cxp_nota_credito;

CREATE TABLE etes.rel_cxp_nota_credito
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  id_eds integer NOT NULL,
  cxp_cuentas_cobro character varying(50) DEFAULT ''::character varying,
  cxp_nota character varying(50) DEFAULT ''::character varying,
  periodo character varying(6) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_id_eds FOREIGN KEY (id_eds)
      REFERENCES etes.estacion_servicio (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE etes.rel_cxp_nota_credito
  OWNER TO postgres;

