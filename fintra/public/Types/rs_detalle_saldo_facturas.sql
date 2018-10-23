-- Type: rs_detalle_saldo_facturas

-- DROP TYPE rs_detalle_saldo_facturas;

CREATE TYPE rs_detalle_saldo_facturas AS
   (documento character varying,
    negocio character varying,
    cuota integer,
    total_factura numeric,
    saldo_capital numeric,
    saldo_interes numeric,
    saldo_cat numeric,
    saldo_cuota_manejo numeric,
    saldo_seguro numeric,
    total_abonos numeric,
    saldo_factura numeric);
ALTER TYPE rs_detalle_saldo_facturas
  OWNER TO postgres;
