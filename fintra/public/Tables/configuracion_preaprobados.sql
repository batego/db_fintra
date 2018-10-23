-- Table: configuracion_preaprobados

-- DROP TABLE configuracion_preaprobados;

CREATE TABLE configuracion_preaprobados
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  id_unidad_negocio integer NOT NULL,
  valor_inicial numeric(11,2) NOT NULL DEFAULT 0,
  valor_final numeric(11,2) NOT NULL DEFAULT 0,
  incremento numeric(11,2) NOT NULL DEFAULT 0,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT id_unidadneg_fk FOREIGN KEY (id_unidad_negocio)
      REFERENCES unidad_negocio (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=TRUE
);
ALTER TABLE configuracion_preaprobados
  OWNER TO postgres;
GRANT ALL ON TABLE configuracion_preaprobados TO postgres;
GRANT SELECT ON TABLE configuracion_preaprobados TO msoto;

