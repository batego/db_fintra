-- Table: opav.sl_facturacion_proyectada

-- DROP TABLE opav.sl_facturacion_proyectada;

CREATE TABLE opav.sl_facturacion_proyectada
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  id_solicitud character varying(15) NOT NULL,
  num_factura character varying(10) NOT NULL DEFAULT ''::character varying,
  valor numeric(19,2) NOT NULL DEFAULT 0,
  dias_ejecucion integer NOT NULL DEFAULT 0,
  fecha_facturacion date NOT NULL,
  dia_pago integer NOT NULL DEFAULT 0,
  valor_amortizacion numeric(19,2) NOT NULL DEFAULT 0,
  valor_retegarantia numeric(19,2) NOT NULL DEFAULT 0,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_facturacion_proyectada
  OWNER TO postgres;
