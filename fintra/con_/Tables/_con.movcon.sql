-- Table: con.movcon

-- DROP TABLE con.movcon;

CREATE TABLE con.movcon
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  num_transaccion serial NOT NULL, -- Numero de Transaccion
  tipo_documento character varying(6) NOT NULL DEFAULT ''::character varying, -- Tipo de documento registrado
  documento character varying(10) NOT NULL DEFAULT ''::character varying, -- Codigo de documento registrado
  cod_cuenta character varying(20) NOT NULL DEFAULT ''::character varying, -- Codigo de cuenta
  cod_auxiliar character varying(20) NOT NULL DEFAULT ''::character varying, -- Codigo de cuenta auxiliar
  periodo character varying(6) NOT NULL DEFAULT ''::character varying, -- Periodo descrito en anio y mes
  valor_debito moneda, -- Valor debito del documento
  valor_credito moneda, -- Valor credito del documento
  moneda character varying(3) NOT NULL DEFAULT ''::character varying, -- Moneda en la que esta descrita el valor debito y credito
  tipo_registro character varying(1) NOT NULL DEFAULT ''::character varying, -- Tipo de registro
  process_date character varying(4) NOT NULL DEFAULT ''::character varying, -- Columna que corresponde a la columna process_date en la tabla MSF900
  transaction_no character varying(8) NOT NULL DEFAULT ''::character varying, -- Columna que corresponde a la columna transaction_no en la tabla MSF900
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE con.movcon
  OWNER TO postgres;
GRANT ALL ON TABLE con.movcon TO postgres;
GRANT SELECT ON TABLE con.movcon TO msoto;
COMMENT ON TABLE con.movcon
  IS 'Tabla para registros de movimientos
contables';
COMMENT ON COLUMN con.movcon.num_transaccion IS 'Numero de Transaccion';
COMMENT ON COLUMN con.movcon.tipo_documento IS 'Tipo de documento registrado';
COMMENT ON COLUMN con.movcon.documento IS 'Codigo de documento registrado';
COMMENT ON COLUMN con.movcon.cod_cuenta IS 'Codigo de cuenta';
COMMENT ON COLUMN con.movcon.cod_auxiliar IS 'Codigo de cuenta auxiliar';
COMMENT ON COLUMN con.movcon.periodo IS 'Periodo descrito en anio y mes';
COMMENT ON COLUMN con.movcon.valor_debito IS 'Valor debito del documento';
COMMENT ON COLUMN con.movcon.valor_credito IS 'Valor credito del documento';
COMMENT ON COLUMN con.movcon.moneda IS 'Moneda en la que esta descrita el valor debito y credito';
COMMENT ON COLUMN con.movcon.tipo_registro IS 'Tipo de registro';
COMMENT ON COLUMN con.movcon.process_date IS 'Columna que corresponde a la columna process_date en la tabla MSF900';
COMMENT ON COLUMN con.movcon.transaction_no IS 'Columna que corresponde a la columna transaction_no en la tabla MSF900';


