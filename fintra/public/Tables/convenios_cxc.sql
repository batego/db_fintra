-- Table: convenios_cxc

-- DROP TABLE convenios_cxc;

CREATE TABLE convenios_cxc
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id_convenio integer NOT NULL,
  titulo_valor character varying(6) NOT NULL,
  prefijo_factura character varying(15) NOT NULL,
  cuenta_cxc character varying(30) NOT NULL,
  hc_cxc character varying(6) NOT NULL,
  genera_remesa boolean, -- indica si el titulo valor genera remesa
  creation_user character varying(10) NOT NULL,
  user_update character varying(10) NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  cuenta_prov_cxc character varying(30) NOT NULL DEFAULT ''::character varying,
  cuenta_prov_cxp character varying(30)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE convenios_cxc
  OWNER TO postgres;
GRANT ALL ON TABLE convenios_cxc TO postgres;
GRANT SELECT ON TABLE convenios_cxc TO msoto;
COMMENT ON TABLE convenios_cxc
  IS 'Títulos valores utilizados para el convenio y documentos cxc generados';
COMMENT ON COLUMN convenios_cxc.genera_remesa IS 'indica si el titulo valor genera remesa';


