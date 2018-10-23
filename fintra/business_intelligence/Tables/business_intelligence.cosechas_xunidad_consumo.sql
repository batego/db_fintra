-- Table: business_intelligence.cosechas_xunidad_consumo

-- DROP TABLE business_intelligence.cosechas_xunidad_consumo;

CREATE TABLE business_intelligence.cosechas_xunidad_consumo
(
  cedula character varying,
  nombre character varying,
  unidad_negocio character varying,
  negocio character varying,
  afiliado character varying,
  fecha_aprobacion character varying,
  fecha_desembolso character varying,
  periodo_desembolso character varying,
  total_desembolsado character varying,
  plazo character varying,
  cuota character varying,
  cuotas_vencidas character varying,
  analista character varying,
  asesor_comercial character varying,
  cobrador_telefonico character varying,
  cobrador_campo character varying,
  fecha_ultimo_pago character varying,
  vencimiento_mayor character varying,
  vencimiento_mayor_maximo character varying,
  tramo_anterior character varying,
  fecha_vencimiento character varying,
  direccion character varying,
  telefono character varying,
  celular character varying,
  email character varying,
  estrato character varying,
  ocupacion character varying,
  departamento character varying,
  municipio character varying,
  barrio character varying,
  nombre_empresa character varying,
  cargo character varying,
  colocacion numeric,
  pagos numeric,
  saldo numeric,
  saldo_porvencer numeric,
  ingresos numeric,
  periodo_negocio character varying,
  creation_date timestamp with time zone DEFAULT now()
)
WITH (
  OIDS=FALSE
);
ALTER TABLE business_intelligence.cosechas_xunidad_consumo
  OWNER TO postgres;

