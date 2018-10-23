-- Table: opav.sl_inventario_facturas

-- DROP TABLE opav.sl_inventario_facturas;

CREATE TABLE opav.sl_inventario_facturas
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  id_inventario integer NOT NULL,
  factura_no character varying(50) NOT NULL DEFAULT ''::character varying,
  valor_factura numeric(15,4) NOT NULL DEFAULT 0,
  ruta_factura character varying(500) NOT NULL DEFAULT ''::character varying,
  lote_envio_apoteosys character varying(20) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_invfact_inventario FOREIGN KEY (id_inventario)
      REFERENCES opav.sl_inventario (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_inventario_facturas
  OWNER TO postgres;
