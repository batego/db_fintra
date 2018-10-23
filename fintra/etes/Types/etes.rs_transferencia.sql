-- Type: etes.rs_transferencia

-- DROP TYPE etes.rs_transferencia;

CREATE TYPE etes.rs_transferencia AS
   (id_transportadora integer,
    transportadora text,
    id_manifiesto integer,
    nombre_agencia text,
    conductor text,
    cedula_propietario text,
    propietario text,
    placa text,
    planilla text,
    fecha_anticipo text,
    usuario_creacion text,
    codigo_proserv text,
    descripcion text,
    reanticipo text,
    usuario_aprobacion text,
    valor_anticipo numeric,
    porcetaje_descuto numeric,
    valor_descuento numeric,
    valor_neto_con_descueto numeric,
    comision numeric,
    valor_consignacion numeric,
    banco text,
    sucursal text,
    cuenta text,
    tipo_cuenta text,
    nombre_cuenta text,
    nit_cuenta text,
    documento_cxp text);
ALTER TYPE etes.rs_transferencia
  OWNER TO postgres;
