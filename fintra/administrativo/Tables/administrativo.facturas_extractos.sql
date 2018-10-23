-- Table: administrativo.facturas_extractos

-- DROP TABLE administrativo.facturas_extractos;

CREATE TABLE administrativo.facturas_extractos
(
  id serial NOT NULL,
  documento character varying(30) NOT NULL DEFAULT ''::character varying,
  negocio character varying(20) NOT NULL DEFAULT ''::character varying,
  cuota numeric(11,2) NOT NULL DEFAULT 0,
  fecha_vencimiento timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  dias_mora numeric(11,2) NOT NULL DEFAULT 0,
  estado character varying(20) NOT NULL DEFAULT ''::character varying,
  valor_factura numeric(11,2) NOT NULL DEFAULT 0,
  valor_abono numeric(11,2) NOT NULL DEFAULT 0,
  valor_saldo numeric(11,2) NOT NULL DEFAULT 0,
  interesxmora numeric(11,2) NOT NULL DEFAULT 0,
  gastocobranza numeric(11,2) NOT NULL DEFAULT 0,
  porcentaje_descuento_intresxmora numeric(11,2) NOT NULL DEFAULT 0,
  porcentaje_descuento_gastocobranza numeric(11,2) NOT NULL DEFAULT 0,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.facturas_extractos
  OWNER TO postgres;

