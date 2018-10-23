-- Table: convenios_remesas

-- DROP TABLE convenios_remesas;

CREATE TABLE convenios_remesas
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id_convenio integer NOT NULL,
  id_remesa serial NOT NULL,
  ciudad_sede character varying(10) NOT NULL,
  banco_titulo character varying(6) NOT NULL,
  ciudad_titulo character varying(6) NOT NULL,
  genera_remesa boolean NOT NULL,
  porcentaje_remesa numeric NOT NULL,
  cuenta_remesa character varying(30) NOT NULL,
  creation_user character varying(10) NOT NULL,
  user_update character varying(10) NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  CONSTRAINT "conveniosremesasFK" FOREIGN KEY (dstrct, id_convenio)
      REFERENCES convenios (dstrct, id_convenio) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT "conveniosremesasFK2" FOREIGN KEY (dstrct, banco_titulo)
      REFERENCES bancos (dstrct, codigo) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE convenios_remesas
  OWNER TO postgres;
GRANT ALL ON TABLE convenios_remesas TO postgres;
GRANT SELECT ON TABLE convenios_remesas TO msoto;
COMMENT ON TABLE convenios_remesas
  IS 'Porcentajes de remesa calculados para el convenio según el banco y la ciudad del título valor';

