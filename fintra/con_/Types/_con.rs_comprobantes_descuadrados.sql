-- Type: con.rs_comprobantes_descuadrados

-- DROP TYPE con.rs_comprobantes_descuadrados;

CREATE TYPE con.rs_comprobantes_descuadrados AS
   (tipodoc character varying(5),
    numdoc character varying(30),
    grupo_transaccion integer,
    total_debito numeric,
    total_credito numeric);
ALTER TYPE con.rs_comprobantes_descuadrados
  OWNER TO postgres;
