-- Table: wsdc.consulta

-- DROP TABLE wsdc.consulta;

CREATE TABLE wsdc.consulta
(
  id serial NOT NULL,
  fecha timestamp without time zone,
  tipo_cuenta character varying,
  entidad character varying,
  oficina character varying,
  ciudad character varying,
  razon character varying,
  tipo_identificacion smallint NOT NULL,
  identificacion character varying NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying NOT NULL,
  creation_user character varying NOT NULL,
  nit_empresa character varying NOT NULL DEFAULT '8020220161'::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT persona_consulta_fk FOREIGN KEY (tipo_identificacion, identificacion, nit_empresa)
      REFERENCES wsdc.persona (tipo_identificacion, identificacion, nit_empresa) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE wsdc.consulta
  OWNER TO postgres;

