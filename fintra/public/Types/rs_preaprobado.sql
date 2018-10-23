-- Type: rs_preaprobado

-- DROP TYPE rs_preaprobado;

CREATE TYPE rs_preaprobado AS
   (id_unidad_negocio integer,
    periodo integer,
    negasoc character varying,
    cedula_deudor character varying,
    nombre_deudor character varying,
    telefono character varying,
    celular character varying,
    direccion character varying,
    barrio character varying,
    ciudad character varying,
    email character varying,
    cedula_codeudor character varying,
    nombre_codeudor character varying,
    telefono_codeudor character varying,
    celular_codeudor character varying,
    cuotas character varying,
    id_convenio character varying,
    afiliado character varying,
    tipo character varying,
    fecha_desembolso character varying,
    fecha_ult_pago character varying,
    dias_pagos character varying,
    vr_negocio numeric,
    valor_factura numeric,
    valor_saldo numeric,
    porcetaje numeric,
    altura_mora character varying,
    altura_mora_actual character varying,
    valor_preaprobado numeric,
    responsable_cuenta character varying,
    cuotas_xpagar integer,
    cuotas_pagadas integer);
ALTER TYPE rs_preaprobado
  OWNER TO postgres;
