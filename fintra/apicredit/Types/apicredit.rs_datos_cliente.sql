-- Type: apicredit.rs_datos_cliente

-- DROP TYPE apicredit.rs_datos_cliente;

CREATE TYPE apicredit.rs_datos_cliente AS
   (ciudad_credito character varying,
    nit_afiliado character varying,
    tipo_carrera character varying,
    dia_pago character varying,
    fecha_pago character varying,
    mora_actual character varying,
    cumple_tiempo character varying,
    cod_neg character varying,
    numero_solicitud_padre integer,
    nombre character varying,
    primer_nombre character varying,
    primer_apellido character varying,
    fecha_nacimiento character varying,
    tipo_identificacion character varying,
    identificacion character varying,
    fecha_expedicion character varying,
    telefono character varying,
    celular character varying,
    tipo_cliente character varying,
    ingresos numeric,
    valor_preaprobado numeric);
ALTER TYPE apicredit.rs_datos_cliente
  OWNER TO postgres;
