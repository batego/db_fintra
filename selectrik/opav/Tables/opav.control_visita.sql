-- Table: opav.control_visita

-- DROP TABLE opav.control_visita;

CREATE TABLE opav.control_visita
(
  id_solicitud character varying(15) NOT NULL,
  fecha_visita timestamp without time zone NOT NULL,
  hora_visita character varying(5) NOT NULL,
  contratista character varying(5) NOT NULL,
  reg_status character varying(1) DEFAULT ''::character varying,
  creation_user character varying(10),
  creation_date timestamp without time zone DEFAULT now(),
  user_update character varying(10),
  last_update timestamp without time zone DEFAULT now(),
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.control_visita
  OWNER TO postgres;
