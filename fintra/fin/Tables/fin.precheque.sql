-- Table: fin.precheque

-- DROP TABLE fin.precheque;

CREATE TABLE fin.precheque
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying, -- estado del registro
  id character varying(8) NOT NULL, -- identificador
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  banco character varying(15) NOT NULL DEFAULT ''::character varying,
  sucursal character varying(30) NOT NULL DEFAULT ''::character varying,
  cheque character varying(12) NOT NULL DEFAULT ''::character varying, -- Cheque impreso
  beneficiario character varying(15) NOT NULL DEFAULT ''::character varying, -- nit del beneficiario
  valor moneda NOT NULL DEFAULT 0,
  moneda character varying(3) NOT NULL DEFAULT ''::character varying,
  proveedor character varying(15) NOT NULL DEFAULT ''::character varying, -- nit proveedor
  agencia character varying(2) NOT NULL DEFAULT ''::character varying, -- Agencia del usuario para ...
  fecha_impresion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  usuario_impresion character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fin.precheque
  OWNER TO postgres;
COMMENT ON TABLE fin.precheque
  IS 'Cheques por imprimir';
COMMENT ON COLUMN fin.precheque.reg_status IS 'estado del registro';
COMMENT ON COLUMN fin.precheque.id IS 'identificador';
COMMENT ON COLUMN fin.precheque.cheque IS 'Cheque impreso';
COMMENT ON COLUMN fin.precheque.beneficiario IS 'nit del beneficiario';
COMMENT ON COLUMN fin.precheque.proveedor IS 'nit proveedor';
COMMENT ON COLUMN fin.precheque.agencia IS 'Agencia del usuario para 
imprimir';


