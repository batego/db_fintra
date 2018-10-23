-- Table: administrativo.rel_condiciones_item_demanda

-- DROP TABLE administrativo.rel_condiciones_item_demanda;

CREATE TABLE administrativo.rel_condiciones_item_demanda
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  id_condicion character varying(10) NOT NULL,
  id_item character varying(50) NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT rel_condiciones_item_demanda_id_condicion_fkey FOREIGN KEY (id_condicion)
      REFERENCES administrativo.condiciones_especiales_demanda (codigo) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.rel_condiciones_item_demanda
  OWNER TO postgres;

