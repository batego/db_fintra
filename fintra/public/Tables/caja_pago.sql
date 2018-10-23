-- Table: caja_pago

-- DROP TABLE caja_pago;

CREATE TABLE caja_pago
(
  id serial NOT NULL, -- id para los pagos
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL,
  agencia character varying(10) NOT NULL, -- Agencia a la que ingresa el dinero
  fecha timestamp without time zone NOT NULL, -- Fecha del ingreso
  transportadora character varying(10) NOT NULL, -- codcli de la transportadora que emite el cheque o vale
  tipo_documento character varying(1) NOT NULL, -- 'C' si es cheque o 'V' si es vale
  num_documento character varying(50) NOT NULL, -- Numero del cheque o vale
  beneficiario character varying(15) NOT NULL, -- nit del beneficiario
  banco character varying(6) NOT NULL, -- codigo del banco del cheque
  valor double precision NOT NULL, -- Valor del ingreso
  comision numeric(5,2) NOT NULL, -- porcentaje de comision cobrado
  valor_comision double precision NOT NULL, -- valor de la comisión
  num_cxc character varying NOT NULL DEFAULT ''::character varying, -- Numero de la cxc generada
  creation_user character varying(10) NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  comision_bancaria double precision,
  CONSTRAINT "pago_bancos_FK" FOREIGN KEY (dstrct, banco)
      REFERENCES bancos (dstrct, codigo) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE caja_pago
  OWNER TO postgres;
GRANT ALL ON TABLE caja_pago TO postgres;
GRANT SELECT ON TABLE caja_pago TO msoto;
COMMENT ON TABLE caja_pago
  IS 'Tabla para registrar los pagos realizados en las cajas';
COMMENT ON COLUMN caja_pago.id IS 'id para los pagos';
COMMENT ON COLUMN caja_pago.agencia IS 'Agencia a la que ingresa el dinero';
COMMENT ON COLUMN caja_pago.fecha IS 'Fecha del ingreso';
COMMENT ON COLUMN caja_pago.transportadora IS 'codcli de la transportadora que emite el cheque o vale';
COMMENT ON COLUMN caja_pago.tipo_documento IS '''C'' si es cheque o ''V'' si es vale';
COMMENT ON COLUMN caja_pago.num_documento IS 'Numero del cheque o vale';
COMMENT ON COLUMN caja_pago.beneficiario IS 'nit del beneficiario';
COMMENT ON COLUMN caja_pago.banco IS 'codigo del banco del cheque';
COMMENT ON COLUMN caja_pago.valor IS 'Valor del ingreso';
COMMENT ON COLUMN caja_pago.comision IS 'porcentaje de comision cobrado';
COMMENT ON COLUMN caja_pago.valor_comision IS 'valor de la comisión';
COMMENT ON COLUMN caja_pago.num_cxc IS 'Numero de la cxc generada';


