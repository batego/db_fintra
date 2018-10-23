-- Table: convenios_comisiones

-- DROP TABLE convenios_comisiones;

CREATE TABLE convenios_comisiones
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id_convenio integer NOT NULL,
  id_comision serial NOT NULL,
  nombre character varying(20) NOT NULL,
  cuenta_comision character varying(30) NOT NULL,
  porcentaje_comision numeric NOT NULL,
  cuenta_contra character varying(30) NOT NULL DEFAULT ''::character varying, -- cuenta de la contrapartida
  indicador_contra boolean NOT NULL DEFAULT false, -- indicador contrapartida
  comision_tercero boolean NOT NULL DEFAULT false, -- indica si esta es la comision del tercero
  creation_user character varying(10) NOT NULL,
  user_update character varying(10) NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  CONSTRAINT "convenioscomisionesFK" FOREIGN KEY (dstrct, id_convenio)
      REFERENCES convenios (dstrct, id_convenio) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE convenios_comisiones
  OWNER TO postgres;
GRANT ALL ON TABLE convenios_comisiones TO postgres;
GRANT SELECT ON TABLE convenios_comisiones TO msoto;
COMMENT ON TABLE convenios_comisiones
  IS 'Comisiones calculadas para el convenio';
COMMENT ON COLUMN convenios_comisiones.cuenta_contra IS 'cuenta de la contrapartida';
COMMENT ON COLUMN convenios_comisiones.indicador_contra IS 'indicador contrapartida';
COMMENT ON COLUMN convenios_comisiones.comision_tercero IS 'indica si esta es la comision del tercero';


