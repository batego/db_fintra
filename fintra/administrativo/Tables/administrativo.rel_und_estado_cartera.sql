-- Table: administrativo.rel_und_estado_cartera

-- DROP TABLE administrativo.rel_und_estado_cartera;

CREATE TABLE administrativo.rel_und_estado_cartera
(
  id serial NOT NULL,
  id_unidad_negocio integer NOT NULL,
  id_intervalo_mora integer NOT NULL,
  id_estado_cartera integer NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT rel_und_estado_cartera_id_estado_cartera_fkey FOREIGN KEY (id_estado_cartera)
      REFERENCES administrativo.estados_cartera (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT rel_und_estado_cartera_id_intervalo_mora_fkey FOREIGN KEY (id_intervalo_mora)
      REFERENCES administrativo.intervalos_mora (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT rel_und_estado_cartera_id_unidad_negocio_fkey FOREIGN KEY (id_unidad_negocio)
      REFERENCES unidad_negocio (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.rel_und_estado_cartera
  OWNER TO postgres;

