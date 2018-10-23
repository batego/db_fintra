-- Table: opav.sl_directorio_estados

-- DROP TABLE opav.sl_directorio_estados;

CREATE TABLE opav.sl_directorio_estados
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id_directorio integer NOT NULL DEFAULT 0,
  nombre character varying(80) NOT NULL DEFAULT ''::character varying,
  descripcion text NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_sl_directorio1 FOREIGN KEY (id_directorio)
      REFERENCES opav.sl_directorio (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_directorio_estados
  OWNER TO postgres;
