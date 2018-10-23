-- Table: opav.sl_rel_minutas_broker

-- DROP TABLE opav.sl_rel_minutas_broker;

CREATE TABLE opav.sl_rel_minutas_broker
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  id_contrato character varying(20) NOT NULL,
  id_broker integer NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  id_beneficiario integer,
  cotizado_broker character varying(1) NOT NULL DEFAULT 'N'::character varying,
  CONSTRAINT sl_rel_minutas_broker_id_broker_fkey FOREIGN KEY (id_broker)
      REFERENCES opav.sl_broker (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT sl_rel_minutas_broker_id_contrato_fkey FOREIGN KEY (id_contrato)
      REFERENCES opav.sl_minutas (numero_contrato) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_rel_minutas_broker
  OWNER TO postgres;
