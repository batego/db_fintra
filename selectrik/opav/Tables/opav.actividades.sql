-- Table: opav.actividades

-- DROP TABLE opav.actividades;

CREATE TABLE opav.actividades
(
  id serial NOT NULL, -- identificador de una actividad
  tipo character varying(20), -- tipo de tabajo para el cual aplica la actividad
  descripcion character varying(100) NOT NULL DEFAULT ''::character varying, -- nombre de la actividad
  peso_predeterminado integer, -- peso que tiene por defecto la actividad dentro de una accion
  reg_status character varying(1) DEFAULT ''::character varying,
  creation_user character varying(10),
  creation_date timestamp without time zone DEFAULT now(),
  user_update character varying(10),
  last_update timestamp without time zone DEFAULT now(),
  orden_predeterminado integer,
  responsable_predeterminado character varying(20) NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.actividades
  OWNER TO postgres;
COMMENT ON TABLE opav.actividades
  IS 'Almacena las distintas opav.actividades disponibles para las acciones de una solicitud';
COMMENT ON COLUMN opav.actividades.id IS 'identificador de una actividad';
COMMENT ON COLUMN opav.actividades.tipo IS 'tipo de tabajo para el cual aplica la actividad';
COMMENT ON COLUMN opav.actividades.descripcion IS 'nombre de la actividad';
COMMENT ON COLUMN opav.actividades.peso_predeterminado IS 'peso que tiene por defecto la actividad dentro de una accion';
