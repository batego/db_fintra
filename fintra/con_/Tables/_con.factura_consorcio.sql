-- Table: con.factura_consorcio

-- DROP TABLE con.factura_consorcio;

CREATE TABLE con.factura_consorcio
(
  documento character varying(10) NOT NULL DEFAULT ''::character varying, -- Numero de la factura
  nit character varying(15) NOT NULL DEFAULT ''::character varying, -- Nit del cliente
  id_cliente character varying(10) NOT NULL DEFAULT ''::character varying, -- Codigo interno del cliente
  fecha_factura date NOT NULL DEFAULT '0099-01-01'::date, -- La fecha de la factura de la primera cuota es la fecha de financiacion. ...
  fecha_vencimiento date NOT NULL DEFAULT '0099-01-01'::date, -- La fecha de vencimiento es 30 dias despues de la fecha de la factura
  valor_factura moneda NOT NULL DEFAULT 0.00, -- Valor total a cobrar al cliente
  valor_capital moneda NOT NULL DEFAULT 0.00, -- Valor capital de la cuota
  valor_interes moneda NOT NULL DEFAULT 0.00, -- Valor de los intereses de la cuota
  id_solicitud character varying(15) NOT NULL DEFAULT ''::character varying, -- Numero de solicitud facturada
  parcial integer NOT NULL DEFAULT 0, -- Parcial de la solicitud. La id_solicitud puede tener varios parciales
  fecha_envio_fiducia timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  documento_consorcio character varying(10) DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE con.factura_consorcio
  OWNER TO postgres;
GRANT ALL ON TABLE con.factura_consorcio TO postgres;
GRANT SELECT ON TABLE con.factura_consorcio TO msoto;
COMMENT ON TABLE con.factura_consorcio
  IS 'Tabla que registra la cabecera de  las facturas nuevas para el consorcio. Indica el valor de la factura, con su valor cuota y valor intereses unicamente.';
COMMENT ON COLUMN con.factura_consorcio.documento IS 'Numero de la factura';
COMMENT ON COLUMN con.factura_consorcio.nit IS 'Nit del cliente';
COMMENT ON COLUMN con.factura_consorcio.id_cliente IS 'Codigo interno del cliente';
COMMENT ON COLUMN con.factura_consorcio.fecha_factura IS 'La fecha de la factura de la primera cuota es la fecha de financiacion. 
Las facturas de las siguientes facturas son 30 dias mas tarde.';
COMMENT ON COLUMN con.factura_consorcio.fecha_vencimiento IS 'La fecha de vencimiento es 30 dias despues de la fecha de la factura';
COMMENT ON COLUMN con.factura_consorcio.valor_factura IS 'Valor total a cobrar al cliente';
COMMENT ON COLUMN con.factura_consorcio.valor_capital IS 'Valor capital de la cuota';
COMMENT ON COLUMN con.factura_consorcio.valor_interes IS 'Valor de los intereses de la cuota';
COMMENT ON COLUMN con.factura_consorcio.id_solicitud IS 'Numero de solicitud facturada';
COMMENT ON COLUMN con.factura_consorcio.parcial IS 'Parcial de la solicitud. La id_solicitud puede tener varios parciales';


