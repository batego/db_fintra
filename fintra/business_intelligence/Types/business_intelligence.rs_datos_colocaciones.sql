-- Type: business_intelligence.rs_datos_colocaciones

-- DROP TYPE business_intelligence.rs_datos_colocaciones;

CREATE TYPE business_intelligence.rs_datos_colocaciones AS
   (identificacion character varying,
    unidad_negocio character varying,
    periodo_negocio character varying,
    nombre_cliente character varying,
    valor_negocio numeric,
    valor_aval numeric,
    numero_creditos integer,
    periodo_nuevo_negocio character varying,
    tipo_cliente character varying,
    estado_nuevo_negocio character varying,
    cod_negocio_nuevo character varying,
    valor_negocio_nuevo numeric);
ALTER TYPE business_intelligence.rs_datos_colocaciones
  OWNER TO postgres;
