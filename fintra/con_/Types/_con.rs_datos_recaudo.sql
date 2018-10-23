-- Type: con.rs_datos_recaudo

-- DROP TYPE con.rs_datos_recaudo;

CREATE TYPE con.rs_datos_recaudo AS
   (anio character varying,
    periodo character varying,
    anio_consignacion character varying,
    periodo_consignacion character varying,
    banco character varying,
    sucursal character varying,
    num_ingreso character varying,
    tipo_documento character varying,
    creation_date character varying,
    nitcli character varying,
    nombre_cliente character varying,
    fecha_consignacion character varying,
    cuenta character varying,
    documento character varying,
    tipo_doc character varying,
    valor_ingreso numeric,
    unidad_negocio character varying,
    negocio character varying,
    cuota character varying,
    descripcion character varying,
    cuenta_banco character varying,
    creation_user character varying);
ALTER TYPE con.rs_datos_recaudo
  OWNER TO postgres;
