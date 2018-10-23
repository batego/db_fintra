-- Table: banco

-- DROP TABLE banco;

CREATE TABLE banco
(
  reg_status character varying NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  branch_code character varying(15) NOT NULL DEFAULT ''::character varying, -- Nombre del banco.
  bank_account_no character varying(30) NOT NULL DEFAULT ''::character varying, -- Nombre de las sucursal.
  agency_id character varying(10) NOT NULL DEFAULT ''::character varying, -- CÃƒÆ’Ã‚Â³digo de la agencia.
  account_number character varying(45) NOT NULL, -- NÃƒÆ’Ã‚Âºmero de la cuenta
  currency character varying(3) NOT NULL DEFAULT now(), -- Moneda que maneja la cuenta.
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  codigo_cuenta character varying(25) NOT NULL DEFAULT ''::character varying,
  posicion_bancaria character varying(1) NOT NULL DEFAULT 'S'::character varying, -- Activo para posiciÃƒÆ’Ã‚Â³n bancaria
  formato character varying(1) DEFAULT ''::character varying, -- Dice 'S' si un banco tiene formato para transferencia.2008-08-22
  account_number_to_txt character varying(45) DEFAULT ''::character varying,
  nit_empresa character varying(15) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE banco
  OWNER TO postgres;
GRANT ALL ON TABLE banco TO postgres;
GRANT SELECT ON TABLE banco TO msoto;
COMMENT ON TABLE banco
  IS 'Tabla donde se registran los bancos.';
COMMENT ON COLUMN banco.branch_code IS 'Nombre del banco.';
COMMENT ON COLUMN banco.bank_account_no IS 'Nombre de las sucursal.';
COMMENT ON COLUMN banco.agency_id IS 'CÃƒÆ’Ã‚Â³digo de la agencia.';
COMMENT ON COLUMN banco.account_number IS 'NÃƒÆ’Ã‚Âºmero de la cuenta';
COMMENT ON COLUMN banco.currency IS 'Moneda que maneja la cuenta.';
COMMENT ON COLUMN banco.posicion_bancaria IS 'Activo para posiciÃƒÆ’Ã‚Â³n bancaria';
COMMENT ON COLUMN banco.formato IS 'Dice ''S'' si un banco tiene formato para transferencia.2008-08-22';


-- Trigger: banco_info_adicional on banco

-- DROP TRIGGER banco_info_adicional ON banco;

CREATE TRIGGER banco_info_adicional
  AFTER INSERT
  ON banco
  FOR EACH ROW
  EXECUTE PROCEDURE insert_banco_info_adicional();


