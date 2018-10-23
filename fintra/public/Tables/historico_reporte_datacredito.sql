-- Table: historico_reporte_datacredito

-- DROP TABLE historico_reporte_datacredito;

CREATE TABLE historico_reporte_datacredito
(
  tipo_identificacion text,
  identificacion character varying(15),
  negocio character varying(15),
  nombre character varying(160),
  situacion_titular text,
  fecha_apertura timestamp without time zone,
  fecha_vencimiento timestamp without time zone,
  fecha_corte_proceso timestamp with time zone,
  dias_mora numeric,
  desembolso moneda,
  saldo_en_mora numeric,
  saldo_capital numeric,
  cuota_mensual moneda,
  numero_cuotas character varying(10),
  cuotas_canceladas numeric,
  cuotas_en_mora numeric,
  fecha_limite_pago date,
  ultimo_pago date,
  ciudad_radicacion character varying(40),
  cod_dane_radicacion text,
  ciudad_residencia character varying,
  cod_dane_residencia text,
  departamento_residencia character varying(10),
  direccion_residencia character varying(160),
  telefono_residencia character varying(15),
  ciudad_laboral character varying,
  cod_dane_laboral text,
  departamento_laboral character varying(6),
  direccion_laboral character varying(60),
  telefono_laboral character varying(15),
  ciudad_correspondencia character varying,
  cod_dane_correspondencia text,
  direccion_correspondencia character varying(160),
  correo_electronico character varying(100),
  celular_solicitante character varying(15),
  tipo character varying(1),
  id serial NOT NULL,
  consecutivo character varying(20) NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  rango1 character varying(20) NOT NULL DEFAULT ''::character varying,
  rango2 character varying(20) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE historico_reporte_datacredito
  OWNER TO postgres;
GRANT ALL ON TABLE historico_reporte_datacredito TO postgres;
GRANT SELECT ON TABLE historico_reporte_datacredito TO msoto;

