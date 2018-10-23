-- Type: rs_type_detalle_factura

-- DROP TYPE rs_type_detalle_factura;

CREATE TYPE rs_type_detalle_factura AS
   (item numeric,
    tipo_documento character varying,
    documento character varying,
    proveedor numeric,
    empleado character varying,
    codigo_cuenta character varying,
    creation_date date,
    descripcion character varying,
    vlr numeric,
    valor numeric,
    cod_impuesto_iva character varying,
    porc_iva numeric,
    valor_iva numeric,
    cod_impuesto_rica character varying,
    porc_rica numeric,
    valor_rica numeric,
    cod_impuesto_riva character varying,
    porc_riva numeric,
    valor_riva numeric,
    cod_impuesto_rtfuente character varying,
    porc_rtfuente numeric,
    valor_rtfuente numeric,
    referencia_1 character varying,
    tipo_referencia_1 character varying,
    referencia_2 character varying,
    tipo_referencia_2 character varying,
    multiservicio character varying,
    numos character varying,
    provedor_cab character varying);
ALTER TYPE rs_type_detalle_factura
  OWNER TO postgres;
