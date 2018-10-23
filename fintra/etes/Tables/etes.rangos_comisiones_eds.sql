-- Table: etes.rangos_comisiones_eds

-- DROP TABLE etes.rangos_comisiones_eds;

CREATE TABLE etes.rangos_comisiones_eds
(
  id serial NOT NULL,
  reg_status character varying(2) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(8) NOT NULL DEFAULT ''::character varying,
  id_config_productos integer NOT NULL,
  galonaje_inicial integer NOT NULL DEFAULT 0,
  galonaje_final integer NOT NULL DEFAULT 0,
  valor_descuento numeric(11,2) NOT NULL DEFAULT 0,
  porcentaje_descuento numeric(10,3) NOT NULL DEFAULT 0,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(20) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_id_confi_productos FOREIGN KEY (id_config_productos)
      REFERENCES etes.configcomerial_productos (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE etes.rangos_comisiones_eds
  OWNER TO postgres;

