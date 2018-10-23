-- Type: business_intelligence.rs_datos_cartera

-- DROP TYPE business_intelligence.rs_datos_cartera;

CREATE TYPE business_intelligence.rs_datos_cartera AS
   (unidad_negocio character varying,
    cod_negocio character varying,
    tipo_negocio character varying,
    identificacion character varying,
    nombre_cliente character varying,
    direccion character varying,
    telefono character varying,
    celular character varying,
    barrio character varying,
    responsable_cuenta character varying,
    tipo_cuota character varying,
    fecha_desembolso date,
    vencimiento_mayor date,
    ultimo_vencimiento date,
    proximo_vencimiento date,
    valor_negocio numeric,
    valor_saldo_foto numeric,
    dias_mora integer,
    valor_cuota numeric,
    cuotas_vencidas integer,
    saldo_actual numeric,
    saldo_por_vencer numeric,
    saldo_total numeric);
ALTER TYPE business_intelligence.rs_datos_cartera
  OWNER TO postgres;
