-- Table: condiciones_aval

-- DROP TABLE condiciones_aval;

CREATE TABLE condiciones_aval
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  id_aval serial NOT NULL,
  id_prov_convenio integer NOT NULL,
  tipo_titulo character varying(6) NOT NULL DEFAULT ''::character varying,
  plazo_primer_titulo integer NOT NULL,
  propietario boolean NOT NULL,
  maneja_remesa boolean NOT NULL,
  creation_user character varying(10) NOT NULL,
  user_update character varying(10) NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT "condicionesavalFK" FOREIGN KEY (id_prov_convenio)
      REFERENCES prov_convenio (id_prov_convenio) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE condiciones_aval
  OWNER TO postgres;
GRANT ALL ON TABLE condiciones_aval TO postgres;
GRANT SELECT ON TABLE condiciones_aval TO msoto;
COMMENT ON TABLE condiciones_aval
  IS 'Condiciones de aval definidas para el afiliado segun convenios  y sectores/subsectores';

