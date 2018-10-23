-- Table: opav.proyecto_distribucion

-- DROP TABLE opav.proyecto_distribucion;

CREATE TABLE opav.proyecto_distribucion
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  proyecto character varying(8) NOT NULL,
  distribucion character varying(30) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  CONSTRAINT "foreingn key" FOREIGN KEY (proyecto)
      REFERENCES opav.tipo_proyecto (cod_proyecto) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.proyecto_distribucion
  OWNER TO postgres;
