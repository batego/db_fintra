-- Table: etes.vehiculo

-- DROP TABLE etes.vehiculo;

CREATE TABLE etes.vehiculo
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  id_propietario integer NOT NULL,
  placa character varying(7) NOT NULL DEFAULT ''::character varying,
  marca character varying(150) NOT NULL DEFAULT ''::character varying,
  modelo character varying(150) NOT NULL DEFAULT ''::character varying,
  servicio character varying(150) NOT NULL DEFAULT ''::character varying,
  tipo_vehiculo character varying(150) NOT NULL DEFAULT ''::character varying,
  veto character varying(1) NOT NULL DEFAULT 'N'::character varying,
  veto_causal character varying(300) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_vehiculo_prop FOREIGN KEY (id_propietario)
      REFERENCES etes.propietario (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE etes.vehiculo
  OWNER TO postgres;

