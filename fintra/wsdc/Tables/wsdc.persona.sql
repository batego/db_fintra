-- Table: wsdc.persona

-- DROP TABLE wsdc.persona;

CREATE TABLE wsdc.persona
(
  tipo_identificacion smallint NOT NULL,
  identificacion character varying NOT NULL,
  estado_id character varying,
  fecha_expedicion_id timestamp without time zone, -- fecha de expedicion de la identificacion
  ciudad_id character varying, -- ciudad de la identificacion
  departamento_id character varying, -- departamento de la identificacion
  nombre character varying,
  nombre_completo character varying,
  primer_apellido character varying,
  segundo_apellido character varying,
  nacionalidad character varying,
  genero character varying,
  estado_civil character varying,
  validada boolean, -- true si esta validado contra la registraduría, false si esta validado contra otras fuentes de información, lo cual incluye otros suscriptores.
  edad_min character varying,
  edad_max character varying,
  ultima_hc timestamp without time zone, -- Fecha en que se le realizó la ultima consulta de Historia de Credito
  ultima_localizacion timestamp without time zone, -- Fecha en que se le realizó la ultima consulta de localizacion
  creation_user character varying NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  nit_empresa character varying NOT NULL DEFAULT '8020220161'::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  tipo_cliente character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE wsdc.persona
  OWNER TO postgres;
COMMENT ON COLUMN wsdc.persona.fecha_expedicion_id IS 'fecha de expedicion de la identificacion';
COMMENT ON COLUMN wsdc.persona.ciudad_id IS 'ciudad de la identificacion';
COMMENT ON COLUMN wsdc.persona.departamento_id IS 'departamento de la identificacion';
COMMENT ON COLUMN wsdc.persona.validada IS 'true si esta validado contra la registraduría, false si esta validado contra otras fuentes de información, lo cual incluye otros suscriptores.';
COMMENT ON COLUMN wsdc.persona.ultima_hc IS 'Fecha en que se le realizó la ultima consulta de Historia de Credito';
COMMENT ON COLUMN wsdc.persona.ultima_localizacion IS 'Fecha en que se le realizó la ultima consulta de localizacion';


