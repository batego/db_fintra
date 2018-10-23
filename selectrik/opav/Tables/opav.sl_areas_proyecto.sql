-- Table: opav.sl_areas_proyecto

-- DROP TABLE opav.sl_areas_proyecto;

CREATE TABLE opav.sl_areas_proyecto
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id_solicitud character varying(15) NOT NULL DEFAULT ''::character varying,
  nombre_area character varying(150) NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_sl_areas_sol FOREIGN KEY (id_solicitud)
      REFERENCES opav.ofertas (id_solicitud) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_areas_proyecto
  OWNER TO postgres;
