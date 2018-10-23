-- Table: etes.rel_vehiculo_transportadora

-- DROP TABLE etes.rel_vehiculo_transportadora;

CREATE TABLE etes.rel_vehiculo_transportadora
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  id_trasportadora integer NOT NULL,
  id_vehiculo integer NOT NULL,
  CONSTRAINT fk_vehitran_transp FOREIGN KEY (id_trasportadora)
      REFERENCES etes.transportadoras (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_vehitran_vehiculo FOREIGN KEY (id_vehiculo)
      REFERENCES etes.vehiculo (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE etes.rel_vehiculo_transportadora
  OWNER TO postgres;

