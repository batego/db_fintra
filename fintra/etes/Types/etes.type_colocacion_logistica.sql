-- Type: etes.type_colocacion_logistica

-- DROP TYPE etes.type_colocacion_logistica;

CREATE TYPE etes.type_colocacion_logistica AS
   (id integer,
    periodo text,
    transportadora text,
    nombre_agencia text,
    cedula_propietario text,
    propietario text,
    cedula_conductor text,
    conductor text,
    placa text,
    sucursal text,
    origen text,
    destino text,
    planilla text,
    fecha_venta timestamp without time zone,
    fecha_anticipo timestamp without time zone,
    tiempo_legalizacion text,
    valor_anticipo numeric(11,2),
    descuentos_fintra numeric(11,2),
    valor_consignacion numeric(11,2),
    reanticipo text,
    num_venta text,
    nombre_eds text,
    kilometraje numeric(11),
    producto text,
    precioxunidad numeric(11,2),
    cantidad_suministrada numeric(12,5),
    total_venta numeric,
    disponible numeric);
ALTER TYPE etes.type_colocacion_logistica
  OWNER TO postgres;
