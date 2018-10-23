-- Table: wsdc.respuesta_personalizada

-- DROP TABLE wsdc.respuesta_personalizada;

CREATE TABLE wsdc.respuesta_personalizada
(
  id serial NOT NULL,
  linea character varying NOT NULL, -- Contenido de una linea de respuesta personalizada
  tipo_identificacion smallint NOT NULL,
  identificacion character varying NOT NULL,
  user_update character varying NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying NOT NULL,
  nit_empresa character varying NOT NULL DEFAULT '8020220161'::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE wsdc.respuesta_personalizada
  OWNER TO postgres;
COMMENT ON COLUMN wsdc.respuesta_personalizada.linea IS 'Contenido de una linea de respuesta personalizada';


