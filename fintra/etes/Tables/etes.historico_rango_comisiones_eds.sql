-- Table: etes.historico_rango_comisiones_eds

-- DROP TABLE etes.historico_rango_comisiones_eds;

CREATE TABLE etes.historico_rango_comisiones_eds
(
  id integer NOT NULL DEFAULT nextval('etes.historico_rango_comisiones_eds_id_seq'::regclass),
  periodo character varying(6) NOT NULL DEFAULT ''::character varying,
  id_config_productos integer NOT NULL DEFAULT 0,
  galonaje_inicial integer NOT NULL DEFAULT 0,
  galonaje_final integer NOT NULL DEFAULT 0,
  valor_descuento numeric(11,2) NOT NULL DEFAULT 0,
  porcentaje_descuento numeric(10,3) NOT NULL DEFAULT 0,
  user_update character varying NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  CONSTRAINT fk_idconfig_productos FOREIGN KEY (id_config_productos)
      REFERENCES etes.configcomerial_productos (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE etes.historico_rango_comisiones_eds
  OWNER TO postgres;

