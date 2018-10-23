-- Table: opav.oferta_ejecucion

-- DROP TABLE opav.oferta_ejecucion;

CREATE TABLE opav.oferta_ejecucion
(
  id_solicitud character varying(15) NOT NULL,
  fecha date NOT NULL, -- fecha en que se realizó el seguimiento
  id_accion character varying(12) NOT NULL,
  id_actividad integer NOT NULL,
  avance numeric NOT NULL, -- Porcentaje de avance de la actividad a la fecha
  reg_status character varying(1) DEFAULT ''::character varying,
  creation_user character varying(10),
  creation_date timestamp without time zone DEFAULT now(),
  user_update character varying(10),
  last_update timestamp without time zone DEFAULT now(),
  avance_esperado numeric NOT NULL, -- porcentaje de avance esperado para la actividad a la fecha
  observaciones text DEFAULT ''::text,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT oejecucion_aprogramacion_fk FOREIGN KEY (id_accion, id_actividad)
      REFERENCES opav.accion_programacion (id_accion, id_actividad) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT oejecucion_oseguimiento_fk FOREIGN KEY (id_solicitud, fecha)
      REFERENCES opav.oferta_seguimiento (id_solicitud, fecha) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.oferta_ejecucion
  OWNER TO postgres;
COMMENT ON TABLE opav.oferta_ejecucion
  IS 'Guarda los detalles de los seguimientos que se le hacen a la ejecucion de las actividades de una solicitud';
COMMENT ON COLUMN opav.oferta_ejecucion.fecha IS 'fecha en que se realizó el seguimiento';
COMMENT ON COLUMN opav.oferta_ejecucion.avance IS 'Porcentaje de avance de la actividad a la fecha';
COMMENT ON COLUMN opav.oferta_ejecucion.avance_esperado IS 'porcentaje de avance esperado para la actividad a la fecha';
