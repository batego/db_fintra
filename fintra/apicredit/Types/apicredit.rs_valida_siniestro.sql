-- Type: apicredit.rs_valida_siniestro

-- DROP TYPE apicredit.rs_valida_siniestro;

CREATE TYPE apicredit.rs_valida_siniestro AS
   (estado_neg character varying,
    comentario character varying,
    causal character varying,
    resdeudor character varying,
    reporte character varying,
    nit_empresa character varying);
ALTER TYPE apicredit.rs_valida_siniestro
  OWNER TO postgres;
