-- Table: opav.oferta_seguimiento

-- DROP TABLE opav.oferta_seguimiento;

CREATE TABLE opav.oferta_seguimiento
(
  id_solicitud character varying NOT NULL,
  fecha date NOT NULL, -- fecha en que se realiza el seguimiento
  observaciones text, -- observaciones realizadas a la solicitud en la fecha
  avance_registrado numeric NOT NULL, -- porcentaje de avance total de la solicitud a la fecha
  reg_status character varying(1) DEFAULT ''::character varying,
  creation_user character varying(10),
  creation_date timestamp without time zone DEFAULT now(),
  user_update character varying(10),
  last_update timestamp without time zone DEFAULT now(),
  avance_esperado numeric NOT NULL, -- porcentaje de avance esperado a la fecha
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.oferta_seguimiento
  OWNER TO postgres;
COMMENT ON TABLE opav.oferta_seguimiento
  IS 'Guarda los seguimientos que se le hacen a la ejecucion de las solicitudes';
COMMENT ON COLUMN opav.oferta_seguimiento.fecha IS 'fecha en que se realiza el seguimiento';
COMMENT ON COLUMN opav.oferta_seguimiento.observaciones IS 'observaciones realizadas a la solicitud en la fecha';
COMMENT ON COLUMN opav.oferta_seguimiento.avance_registrado IS 'porcentaje de avance total de la solicitud a la fecha';
COMMENT ON COLUMN opav.oferta_seguimiento.avance_esperado IS 'porcentaje de avance esperado a la fecha';
