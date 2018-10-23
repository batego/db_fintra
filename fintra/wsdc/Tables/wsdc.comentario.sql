-- Table: wsdc.comentario

-- DROP TABLE wsdc.comentario;

CREATE TABLE wsdc.comentario
(
  id serial NOT NULL,
  tipo character varying,
  fecha_vencimiento timestamp without time zone,
  texto character varying, -- Texto del comentario
  tipo_identificacion smallint NOT NULL,
  identificacion character varying NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying NOT NULL,
  creation_user character varying NOT NULL,
  nit_empresa character varying NOT NULL DEFAULT '8020220161'::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT persona_comentario_fk FOREIGN KEY (tipo_identificacion, identificacion, nit_empresa)
      REFERENCES wsdc.persona (tipo_identificacion, identificacion, nit_empresa) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE wsdc.comentario
  OWNER TO postgres;
COMMENT ON COLUMN wsdc.comentario.texto IS 'Texto del comentario';


