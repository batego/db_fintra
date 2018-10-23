-- Table: opav.sl_factura_venta

-- DROP TABLE opav.sl_factura_venta;

CREATE TABLE opav.sl_factura_venta
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  id_solicitud character varying(11) NOT NULL,
  num_factura character varying(20) NOT NULL DEFAULT ''::character varying,
  valor numeric(11,2) NOT NULL DEFAULT 0,
  fecha_facturacion date NOT NULL,
  fecha_vencimiento date NOT NULL,
  dia_pago integer NOT NULL DEFAULT 0,
  valor_amortizacion numeric(11,2) NOT NULL DEFAULT 0,
  valor_retegarantia numeric(11,2) NOT NULL DEFAULT 0,
  foms_corte character varying(20) NOT NULL DEFAULT ''::character varying,
  valor_foms_corte numeric(11,2) NOT NULL DEFAULT 0,
  total numeric(11,2) NOT NULL DEFAULT 0,
  mandado_cliente character varying(2) NOT NULL DEFAULT 'NO'::character varying,
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(10),
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_factura_venta
  OWNER TO postgres;
