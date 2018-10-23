-- Table: etes.agencias

-- DROP TABLE etes.agencias;

CREATE TABLE etes.agencias
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  id_transportadora integer NOT NULL,
  cod_agencia character varying(8) NOT NULL DEFAULT ''::character varying,
  nombre_agencia character varying(300) NOT NULL DEFAULT ''::character varying,
  cod_municipio character varying(300) NOT NULL DEFAULT ''::character varying,
  direccion character varying(100) NOT NULL DEFAULT ''::character varying,
  correo character varying(70) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_id_agencia_transp FOREIGN KEY (id_transportadora)
      REFERENCES etes.transportadoras (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE etes.agencias
  OWNER TO postgres;

