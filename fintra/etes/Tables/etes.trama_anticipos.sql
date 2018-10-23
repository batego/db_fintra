-- Table: etes.trama_anticipos

-- DROP TABLE etes.trama_anticipos;

CREATE TABLE etes.trama_anticipos
(
  id serial NOT NULL,
  json character varying NOT NULL,
  id_empresa integer NOT NULL,
  procesado boolean NOT NULL DEFAULT false,
  tipo_trama character varying(30) NOT NULL,
  exceptions character varying NOT NULL DEFAULT ''::character varying,
  observaciones character varying NOT NULL DEFAULT ''::character varying,
  fecha_inicio_proceso timestamp without time zone NOT NULL DEFAULT now(),
  fecha_fin_proceso timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  creation_user character varying(20) NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  CONSTRAINT fk_idempresa FOREIGN KEY (id_empresa)
      REFERENCES etes.transportadoras (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE etes.trama_anticipos
  OWNER TO postgres;

