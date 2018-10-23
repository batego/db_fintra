-- Type: rs_clasificacion_cliente

-- DROP TYPE rs_clasificacion_cliente;

CREATE TYPE rs_clasificacion_cliente AS
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
    cuotas integer,
    id_convenio character varying,
    afiliado character varying,
    tipo character varying,
    fecha_desembolso character varying,
    fecha_ult_pago character varying,
    dias_pagos character varying,
    vr_negocio numeric,
    valor_factura numeric,
    valor_saldo numeric,
    porcentaje numeric,
    altura_mora_maxima character varying,
    valor_preaprobado numeric,
    clasificacion character varying,
    altura_mora_actual character varying,
    cuotas_xpagar integer,
    cuotas_pagadas integer);
ALTER TYPE rs_clasificacion_cliente
  OWNER TO postgres;
