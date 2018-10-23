-- Table: administrativo.planes_aseguradoras

-- DROP TABLE administrativo.planes_aseguradoras;

CREATE TABLE administrativo.planes_aseguradoras
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id_aseguradora integer,
  nombre_plan character varying(25) NOT NULL DEFAULT ''::character varying,
  vigencia character varying(25) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_pa_aseguradora_id FOREIGN KEY (id_aseguradora)
      REFERENCES administrativo.aseguradora (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.planes_aseguradoras
  OWNER TO postgres;

