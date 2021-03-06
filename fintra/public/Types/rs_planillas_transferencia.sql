-- Type: rs_planillas_transferencia

-- DROP TYPE rs_planillas_transferencia;

CREATE TYPE rs_planillas_transferencia AS
   (id integer,
    reg_status character varying(10),
    observacion_anulacion character varying(50),
    dstrct character varying(10),
    agency_id character varying(10),
    pla_owner character varying(20),
    planilla character varying(10),
    supplier character varying(10),
    proveedor_anticipo character varying(20),
    concept_code character varying(20),
    vlr numeric,
    vlr_for numeric,
    currency character varying(3),
    fecha_anticipo character varying(16),
    fecha_envio_fintra character varying(16),
    aprobado character varying(1),
    fecha_autorizacion character varying(16),
    user_autorizacion character varying(10),
    transferido character varying(1),
    fecha_transferencia character varying(16),
    banco_transferencia character varying(30),
    cuenta_transferencia character varying(20),
    tcta_transferencia character varying(4),
    user_transferencia character varying(10),
    banco character varying(30),
    sucursal character varying(30),
    nombre_cuenta character varying(50),
    cuenta character varying(20),
    tipo_cuenta character varying(2),
    nit_cuenta character varying(20),
    fecha_migracion character varying(16),
    user_migracion character varying(10),
    factura_mims character varying(20),
    vlr_mims_tercero numeric,
    vlr_mims_propietario numeric,
    estado_pago_tercero character varying(30),
    estado_desc_propietario character varying(30),
    fecha_pago_tercero character varying(16),
    fecha_desc_propietario character varying(16),
    cheque_pago_tercero character varying(20),
    cheque_desc_propietario character varying(20),
    corrida_pago_tercero character varying(20),
    corrida_desc_propietario character varying(20),
    nombre_agencia character varying(20),
    nombre_proveedor character varying(160),
    nombre_prpietario character varying(160),
    porcentaje numeric,
    vlr_descuento numeric,
    vlr_neto numeric,
    vlr_combancaria numeric,
    vlr_consignacion numeric,
    reanticipo character varying(1),
    cedcon character varying(20),
    transferencia character varying(20),
    liquidacion character varying(20),
    secuencia integer,
    diferencia character varying(20),
    rango character varying(20),
    creation_user character varying(20),
    descripcion character varying(50),
    periodo_contabilizacion character varying(20),
    docum_contable character varying(20),
    asesor character varying(20),
    referenciado character varying(20),
    status character varying(20),
    obs character varying(20));
ALTER TYPE rs_planillas_transferencia
  OWNER TO postgres;
