-- Table: negocios_comisiones

-- DROP TABLE negocios_comisiones;

CREATE TABLE negocios_comisiones
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id_convenio integer NOT NULL,
  id_comision integer NOT NULL,
  cod_neg character varying(15) NOT NULL,
  porcentaje_comision numeric NOT NULL,
  valor_comision numeric NOT NULL,
  creation_user character varying(10) NOT NULL,
  user_update character varying(10) NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  CONSTRAINT "convenioscomisionesFK" FOREIGN KEY (dstrct, id_convenio, id_comision)
      REFERENCES convenios_comisiones (dstrct, id_convenio, id_comision) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT "negociosFK" FOREIGN KEY (cod_neg)
      REFERENCES negocios (cod_neg) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE negocios_comisiones
  OWNER TO postgres;
GRANT ALL ON TABLE negocios_comisiones TO postgres;
GRANT SELECT ON TABLE negocios_comisiones TO msoto;

