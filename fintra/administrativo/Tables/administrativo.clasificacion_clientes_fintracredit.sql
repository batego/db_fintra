-- Table: administrativo.clasificacion_clientes_fintracredit

-- DROP TABLE administrativo.clasificacion_clientes_fintracredit;

CREATE TABLE administrativo.clasificacion_clientes_fintracredit
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(6) NOT NULL DEFAULT 'FINV'::character varying,
  id_unidad_negocio integer,
  periodo integer,
  negasoc character varying,
  cedula_deudor character varying,
  nombre_deudor character varying,
  telefono character varying,
  celular character varying,
  direccion character varying,
  barrio character varying,
  ciudad character varying,
  email character varying,
  cedula_codeudor character varying,
  nombre_codeudor character varying,
  telefono_codeudor character varying,
  celular_codeudor character varying,
  id_convenio character varying,
  afiliado character varying,
  tipo character varying,
  fecha_desembolso character varying,
  clasificacion character varying,
  fecha_ult_pago character varying,
  dias_ultimo_pago character varying,
  altura_mora_maxima character varying,
  altura_mora_actual character varying,
  numero_cuotas integer,
  cuotas_pagadas integer,
  cuotas_xpagar integer,
  cuotas_restantes_xpagar integer,
  vr_negocio numeric,
  valor_factura numeric,
  valor_saldo numeric,
  porcentaje_cump numeric,
  valor_preaprobado numeric,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(15) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT id_unidadnegocio_fc_fk FOREIGN KEY (id_unidad_negocio)
      REFERENCES unidad_negocio (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.clasificacion_clientes_fintracredit
  OWNER TO postgres;

