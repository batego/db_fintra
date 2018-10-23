-- Table: convenios_cxc_fiducias

-- DROP TABLE convenios_cxc_fiducias;

CREATE TABLE convenios_cxc_fiducias
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id_convenio integer NOT NULL,
  nit_fiducia character varying(15) NOT NULL DEFAULT ''::character varying,
  titulo_valor character varying(6) NOT NULL,
  prefijo_cxc_fiducia character varying(15) NOT NULL DEFAULT ''::character varying,
  hc_cxc_fiducia character varying(6) NOT NULL DEFAULT ''::character varying,
  cuenta_cxc_fiducia character varying(30) NOT NULL DEFAULT ''::character varying,
  creation_user character varying(10) NOT NULL,
  user_update character varying(10) NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  prefijo_factura_endoso character varying(15) NOT NULL DEFAULT ''::character varying,
  hc_cxc_endoso character varying(2) NOT NULL DEFAULT ''::character varying,
  cuenta_cxc_endoso character varying(15) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT "convenios_fiduciasFK" FOREIGN KEY (dstrct, id_convenio, nit_fiducia)
      REFERENCES convenios_fiducias (dstrct, id_convenio, nit_fiducia) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "convenioscxcfiduciasFK" FOREIGN KEY (dstrct, id_convenio, titulo_valor)
      REFERENCES convenios_cxc (dstrct, id_convenio, titulo_valor) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE convenios_cxc_fiducias
  OWNER TO postgres;
GRANT ALL ON TABLE convenios_cxc_fiducias TO postgres;
GRANT SELECT ON TABLE convenios_cxc_fiducias TO msoto;

