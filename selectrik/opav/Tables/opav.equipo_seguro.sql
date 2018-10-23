-- Table: opav.equipo_seguro

-- DROP TABLE opav.equipo_seguro;

CREATE TABLE opav.equipo_seguro
(
  id_solicitud character varying(15) NOT NULL,
  cod_material character varying(10) NOT NULL,
  item integer NOT NULL DEFAULT 0,
  formulario character varying(10) NOT NULL,
  garantia character varying(15) NOT NULL,
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
ALTER TABLE opav.equipo_seguro
  OWNER TO postgres;
