-- Table: opav.accion_programacion

-- DROP TABLE opav.accion_programacion;

CREATE TABLE opav.accion_programacion
(
  id_accion character varying(12) NOT NULL,
  id_actividad integer NOT NULL,
  responsable character varying(20), -- responsable de la actividad
  peso integer, -- peso de la actividad dentro de la accion
  fecha_inicial timestamp without time zone, -- fecha de inicio de la actividad
  fecha_final timestamp without time zone, -- fecha de finalización de la actividad
  reg_status character varying(1) DEFAULT ''::character varying,
  creation_user character varying(10),
  creation_date timestamp without time zone DEFAULT now(),
  user_update character varying(10),
  last_update timestamp without time zone DEFAULT now(),
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT aprogramacion_actividades_fk FOREIGN KEY (id_actividad)
      REFERENCES opav.actividades (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.accion_programacion
  OWNER TO postgres;
COMMENT ON TABLE opav.accion_programacion
  IS 'Guarda la programacion de las actividades para cada accion';
COMMENT ON COLUMN opav.accion_programacion.responsable IS 'responsable de la actividad';
COMMENT ON COLUMN opav.accion_programacion.peso IS 'peso de la actividad dentro de la accion';
COMMENT ON COLUMN opav.accion_programacion.fecha_inicial IS 'fecha de inicio de la actividad';
COMMENT ON COLUMN opav.accion_programacion.fecha_final IS 'fecha de finalización de la actividad';
