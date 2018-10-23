-- Type: comportamiento_pagos_recaudos

-- DROP TYPE comportamiento_pagos_recaudos;

CREATE TYPE comportamiento_pagos_recaudos AS
   (periodo_cxp character varying,
    tipo_documento character varying,
    documento character varying,
    tercero character varying,
    nombre_proveedor character varying,
    banco character varying,
    sucursal character varying,
    negocio character varying,
    estado_negocio character varying,
    fecha_desembolso date,
    periodo_desembolso character varying,
    fecha_documento date,
    fecha_vencimiento date,
    estado_cxp character varying,
    valor_neto character varying,
    valor_saldo character varying,
    numero_egreso character varying,
    numero_nota character varying,
    tipo_pago integer,
    valor_nota numeric,
    periodo_nota character varying,
    valor_egreso numeric,
    periodo_egreso character varying);
ALTER TYPE comportamiento_pagos_recaudos
  OWNER TO postgres;
