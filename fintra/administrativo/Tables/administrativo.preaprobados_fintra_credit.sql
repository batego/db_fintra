-- Table: administrativo.preaprobados_fintra_credit

-- DROP TABLE administrativo.preaprobados_fintra_credit;

CREATE TABLE administrativo.preaprobados_fintra_credit
(
  id serial NOT NULL,
  id_unidad_negocio integer,
  periodo integer,
  negasoc character varying(15),
  cedula_deudor character varying(15),
  nombre_deudor character varying(160),
  telefono character varying(100),
  celular character varying(100),
  direccion character varying(100),
  barrio character varying,
  ciudad character varying,
  email character varying,
  cedula_codeudor character varying,
  nombre_codeudor character varying,
  telefono_codeudor character varying,
  celular_codeudor character varying,
  cuotas integer,
  id_convenio integer,
  afiliado text,
  tipo text,
  fecha_desembolso date,
  fecha_ult_pago date,
  dias_pagos integer,
  vr_negocio moneda,
  valor_factura numeric,
  valor_saldo numeric,
  porcetaje numeric,
  altura_mora character varying,
  valor_preaprobado numeric,
  CONSTRAINT id_unidadneg_fc_fk FOREIGN KEY (id_unidad_negocio)
      REFERENCES unidad_negocio (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.preaprobados_fintra_credit
  OWNER TO postgres;

