-- Table: subclientes_ofertas04032010

-- DROP TABLE subclientes_ofertas04032010;

CREATE TABLE subclientes_ofertas04032010
(
  id_cliente character varying(10),
  id_solicitud character varying(15),
  porc_cuota_inicial numeric(5,2),
  val_cuota_inicial moneda,
  val_cuota moneda,
  periodo numeric(2,0),
  last_update timestamp without time zone,
  creation_date character varying,
  creation_user character varying(10),
  user_update character varying(10),
  reg_status character varying(1),
  nic character varying(10),
  tasa numeric(5,2),
  valor_base moneda,
  estudio_economico character varying(50),
  porc_base numeric(5,2),
  meses_mora integer,
  fecha_financiacion timestamp without time zone,
  parcial integer,
  tipo_punto character varying(10),
  clase_dtf character varying(10),
  punto numeric(6,3),
  dtf_semanal numeric(6,3),
  val_sin_iva moneda,
  porcentaje_base numeric(5,2),
  base_1 moneda,
  porcentaje_incremento numeric(6,3),
  porcentaje_extemporaneo numeric(7,5),
  val_extemporaneo_1 moneda,
  base_2 moneda,
  base_3 moneda,
  iva moneda,
  iva_base moneda,
  val_extemporaneo_2 moneda,
  subtotal_iva moneda,
  val_a_financiar moneda,
  intereses moneda,
  val_con_financiacion moneda,
  cuota_pago moneda,
  porcentaje_interes numeric(6,3),
  prefacturar character varying(1),
  factura_cliente character varying(15),
  simbolo_variable text,
  observacion text,
  fecha_factura date,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE subclientes_ofertas04032010
  OWNER TO postgres;
GRANT ALL ON TABLE subclientes_ofertas04032010 TO postgres;
GRANT SELECT ON TABLE subclientes_ofertas04032010 TO msoto;

