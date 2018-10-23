-- Type: rs_facturasneg

-- DROP TYPE rs_facturasneg;

CREATE TYPE rs_facturasneg AS
   (documento character varying,
    valor_saldo numeric(15));
ALTER TYPE rs_facturasneg
  OWNER TO postgres;
