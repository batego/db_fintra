-- Table: prov_convenio_rangos

-- DROP TABLE prov_convenio_rangos;

CREATE TABLE prov_convenio_rangos
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  id_prov_convenio serial NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  cuota_ini numeric NOT NULL,
  cuota_fin numeric NOT NULL,
  porcentaje_comision numeric NOT NULL,
  creation_user character varying(10) NOT NULL,
  user_update character varying(10) NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  CONSTRAINT "provconveniorangosFK" FOREIGN KEY (id_prov_convenio)
      REFERENCES prov_convenio (id_prov_convenio) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE prov_convenio_rangos
  OWNER TO postgres;
GRANT ALL ON TABLE prov_convenio_rangos TO postgres;
GRANT SELECT ON TABLE prov_convenio_rangos TO msoto;
COMMENT ON TABLE prov_convenio_rangos
  IS 'Porcentaje de comisión para el afiliado según convenios y sectores/subsectores para los cuales el afiliado puede generar negocios';

