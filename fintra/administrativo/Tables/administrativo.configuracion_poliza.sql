-- Table: administrativo.configuracion_poliza

-- DROP TABLE administrativo.configuracion_poliza;

CREATE TABLE administrativo.configuracion_poliza
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id_aseguradora integer,
  id_poliza integer,
  tdoc_cxc character varying(3) NOT NULL DEFAULT 'FAC'::character varying,
  cuenta_cxc character varying(25) NOT NULL DEFAULT ''::character varying,
  tdoc_cxp character varying(3) NOT NULL DEFAULT 'FAP'::character varying,
  prefijo_cxp character varying(2) NOT NULL DEFAULT ''::character varying,
  hc_cabecera character varying(25) NOT NULL DEFAULT ''::character varying,
  detalle_cxp character varying(25) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_cp_aseguradora_id FOREIGN KEY (id_aseguradora)
      REFERENCES administrativo.aseguradora (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_cp_poliza_id FOREIGN KEY (id_poliza)
      REFERENCES administrativo.polizas (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.configuracion_poliza
  OWNER TO postgres;

