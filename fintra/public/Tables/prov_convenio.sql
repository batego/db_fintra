-- Table: prov_convenio

-- DROP TABLE prov_convenio;

CREATE TABLE prov_convenio
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  id_prov_convenio serial NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  nit_proveedor character varying(15) NOT NULL DEFAULT ''::character varying,
  id_convenio integer NOT NULL,
  cod_sector character varying NOT NULL,
  cod_subsector character varying NOT NULL,
  porcentaje_afiliado numeric NOT NULL,
  cuenta_comision character varying(30) NOT NULL,
  valor_cobertura numeric NOT NULL,
  porc_cobertura_flotante numeric NOT NULL,
  tasa_interes numeric NOT NULL,
  valor_custodia numeric NOT NULL,
  creation_user character varying(10) NOT NULL,
  user_update character varying(10) NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  comision boolean NOT NULL DEFAULT false,
  nombre_afiliado character varying(100),
  departamento character varying(10),
  CONSTRAINT "provconvenioFK1" FOREIGN KEY (dstrct, nit_proveedor)
      REFERENCES proveedor (dstrct, nit) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT "provconvenioFK2" FOREIGN KEY (dstrct, id_convenio)
      REFERENCES convenios (dstrct, id_convenio) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "provconvenioFK3" FOREIGN KEY (cod_sector, cod_subsector)
      REFERENCES subsector (cod_sector, cod_subsector) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE prov_convenio
  OWNER TO postgres;
GRANT ALL ON TABLE prov_convenio TO postgres;
GRANT SELECT ON TABLE prov_convenio TO msoto;
COMMENT ON TABLE prov_convenio
  IS 'Convenios y sectores/subsectores para los cuales el afiliado puede generar negocios';

