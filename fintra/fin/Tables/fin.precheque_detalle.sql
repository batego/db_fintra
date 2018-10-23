-- Table: fin.precheque_detalle

-- DROP TABLE fin.precheque_detalle;

CREATE TABLE fin.precheque_detalle
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  id character varying(8) NOT NULL, -- identificador del registro
  item character varying(3) NOT NULL DEFAULT ''::character varying, -- numero del item del cheque
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  proveedor character varying(15) NOT NULL DEFAULT ''::character varying, -- proveedor de la factura
  tipo_documento character varying(3) NOT NULL DEFAULT ''::character varying, -- Tipo de Documento
  documento character varying(30) NOT NULL DEFAULT ''::character varying, -- numero de factura
  valor moneda NOT NULL DEFAULT 0, -- valor a abonar a la factura
  tipo_pago character varying(1) NOT NULL DEFAULT ''::character varying, -- Abono o cancelacion a factura
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT precheque_detalle_fkey FOREIGN KEY (id)
      REFERENCES fin.precheque (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fin.precheque_detalle
  OWNER TO postgres;
COMMENT ON TABLE fin.precheque_detalle
  IS 'Detalle de precheque';
COMMENT ON COLUMN fin.precheque_detalle.id IS 'identificador del registro';
COMMENT ON COLUMN fin.precheque_detalle.item IS 'numero del item del cheque';
COMMENT ON COLUMN fin.precheque_detalle.proveedor IS 'proveedor de la factura';
COMMENT ON COLUMN fin.precheque_detalle.tipo_documento IS 'Tipo de Documento';
COMMENT ON COLUMN fin.precheque_detalle.documento IS 'numero de factura';
COMMENT ON COLUMN fin.precheque_detalle.valor IS 'valor a abonar a la factura';
COMMENT ON COLUMN fin.precheque_detalle.tipo_pago IS 'Abono o cancelacion a factura';


