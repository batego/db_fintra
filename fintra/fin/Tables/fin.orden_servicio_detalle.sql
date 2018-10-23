-- Table: fin.orden_servicio_detalle

-- DROP TABLE fin.orden_servicio_detalle;

CREATE TABLE fin.orden_servicio_detalle
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(15) NOT NULL DEFAULT ''::character varying,
  tipo_operacion character varying(20) NOT NULL DEFAULT ''::character varying,
  numero_operacion character varying(20) NOT NULL DEFAULT ''::character varying,
  tipo_documento character varying(6) NOT NULL DEFAULT ''::character varying,
  documento character varying(30) NOT NULL DEFAULT ''::character varying,
  proveedor character varying(15) NOT NULL DEFAULT ''::character varying,
  clase character varying(6) NOT NULL DEFAULT ''::character varying,
  valor_calculado moneda,
  placa character varying(7) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT (now())::timestamp without time zone,
  user_update character varying NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT (now())::timestamp without time zone,
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  factura_cxc character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE fin.orden_servicio_detalle
  OWNER TO postgres;

