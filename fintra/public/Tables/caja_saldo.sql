-- Table: caja_saldo

-- DROP TABLE caja_saldo;

CREATE TABLE caja_saldo
(
  dstrct character varying(4) NOT NULL,
  agencia character varying(10) NOT NULL, -- Agencia a la que ingresa el dinero
  fecha date NOT NULL, -- Fecha del ingreso
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  saldo_inicial double precision NOT NULL, -- saldo inicial que tiene la agencia en la fecha
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE caja_saldo
  OWNER TO postgres;
GRANT ALL ON TABLE caja_saldo TO postgres;
GRANT SELECT ON TABLE caja_saldo TO msoto;
COMMENT ON TABLE caja_saldo
  IS 'Tabla para guardar el historico de saldos';
COMMENT ON COLUMN caja_saldo.agencia IS 'Agencia a la que ingresa el dinero';
COMMENT ON COLUMN caja_saldo.fecha IS 'Fecha del ingreso';
COMMENT ON COLUMN caja_saldo.saldo_inicial IS 'saldo inicial que tiene la agencia en la fecha';


