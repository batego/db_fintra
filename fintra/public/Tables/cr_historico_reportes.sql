-- Table: cr_historico_reportes

-- DROP TABLE cr_historico_reportes;

CREATE TABLE cr_historico_reportes
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  id_unidad_negocio integer NOT NULL,
  periodo_lote character varying(6),
  tipo_identificacion text,
  identificacion character varying(40),
  negocio character varying(40),
  nombre character varying(200),
  situacion_titular text,
  fecha_apertura character varying(30) NOT NULL DEFAULT ''::character varying,
  fecha_vencimiento character varying(30) NOT NULL DEFAULT ''::character varying,
  fecha_corte_proceso timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  dias_mora numeric,
  novedad character varying(200),
  min_dias_mora numeric,
  desembolso character varying(20),
  saldo_deuda numeric,
  saldo_en_mora numeric,
  cuota_mensual character varying(20),
  numero_cuotas character varying(20),
  cuotas_canceladas numeric,
  cuotas_en_mora numeric,
  fecha_limite_pago date,
  ultimo_pago date,
  ciudad_radicacion character varying(80),
  cod_dane_radicacion text,
  ciudad_residencia character varying,
  cod_dane_residencia text,
  departamento_residencia character varying(40),
  direccion_residencia character varying(200),
  telefono_residencia character varying(40),
  ciudad_laboral character varying,
  cod_dane_laboral text,
  departamento_laboral character varying(60),
  direccion_laboral character varying(60),
  telefono_laboral character varying(40),
  ciudad_correspondencia character varying,
  cod_dane_correspondencia text,
  direccion_correspondencia character varying(200),
  correo_electronico character varying(200),
  celular_solicitante character varying(40),
  tipo character varying(1),
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cr_historico_reportes
  OWNER TO postgres;
GRANT ALL ON TABLE cr_historico_reportes TO postgres;
GRANT SELECT ON TABLE cr_historico_reportes TO msoto;

