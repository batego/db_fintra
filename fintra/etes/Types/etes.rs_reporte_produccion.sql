-- Type: etes.rs_reporte_produccion

-- DROP TYPE etes.rs_reporte_produccion;

CREATE TYPE etes.rs_reporte_produccion AS
   (id integer,
    estado text,
    obs_anulacion text,
    producto text,
    nombre_agencia text,
    nit_conductor text,
    nombre_conductor text,
    veto text,
    veto_causal text,
    nit_propietario text,
    nombre_propietario text,
    veto_propietario text,
    veto_causal_propietario text,
    placa text,
    planilla text,
    fecha_anticipo timestamp without time zone,
    fecha_envio timestamp without time zone,
    fecha_creacion_fintra timestamp without time zone,
    reanticipo text,
    usuario_creacion text,
    aprobado text,
    transferido text,
    banco_transferencia text,
    cuenta_transferencia text,
    tipo_cuenta_transferencia text,
    banco text,
    cuenta text,
    tipo_cuenta text,
    nombre_cuenta text,
    nit_cuenta text,
    valor_manifiesto numeric,
    valor_anticipo numeric,
    porcentanje_dscto_anttransferencia_1 numeric,
    valor_dscto_1 numeric,
    porcentanje_dscto_descuentoaterceros_2 numeric,
    valor_dscto_2 numeric,
    total_dscto numeric,
    valor_anticipo_con_descuento numeric,
    valor_comision numeric,
    valor_consignado numeric,
    fecha_transferencia timestamp without time zone,
    numero_egreso text,
    valor_egreso numeric,
    id_transportadora integer,
    transportadora text,
    origen text,
    destino text,
    nro_corrida text,
    legalizacion text);
ALTER TYPE etes.rs_reporte_produccion
  OWNER TO postgres;