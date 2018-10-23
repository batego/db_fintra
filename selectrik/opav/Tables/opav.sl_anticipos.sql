-- Table: opav.sl_anticipos

-- DROP TABLE opav.sl_anticipos;

CREATE TABLE opav.sl_anticipos
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT 'FINV'::character varying,
  cod_anticipo character varying(11) NOT NULL DEFAULT ''::character varying,
  id_solicitud character varying(11) NOT NULL DEFAULT ''::character varying,
  cod_cli character varying(10) NOT NULL DEFAULT ''::character varying,
  cod_cotizacion character varying(15) NOT NULL DEFAULT ''::character varying,
  porc_anticipo numeric(11,2) NOT NULL DEFAULT 0,
  valor_anticipo numeric(11,2) NOT NULL DEFAULT 0,
  num_factura character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  num_cxp character varying(10) NOT NULL DEFAULT ''::character varying,
  tipo_anticipo character varying NOT NULL DEFAULT ''::character varying,
  CONSTRAINT sl_anticipos_fk FOREIGN KEY (id_solicitud)
      REFERENCES opav.ofertas (id_solicitud) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_anticipos
  OWNER TO postgres;
