-- Table: recaudo.facturas_rop_duplicado

-- DROP TABLE recaudo.facturas_rop_duplicado;

CREATE TABLE recaudo.facturas_rop_duplicado
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(8) NOT NULL DEFAULT 'FINV'::character varying,
  codigo_duplicado character varying(15) NOT NULL DEFAULT ''::character varying,
  documento character varying(30) NOT NULL DEFAULT ''::character varying,
  negocio character varying(20) NOT NULL DEFAULT ''::character varying,
  cuota character varying(20) NOT NULL DEFAULT ''::character varying,
  fecha_vencimiento timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  dias_mora character varying(20) NOT NULL DEFAULT ''::character varying,
  estado_cartera character varying(20) NOT NULL DEFAULT ''::character varying,
  valor_saldo numeric(11,2) NOT NULL DEFAULT 0,
  valor_capital numeric(11,2) NOT NULL DEFAULT 0,
  valor_interes numeric(11,2) NOT NULL DEFAULT 0,
  valor_intxmora numeric(11,2) NOT NULL DEFAULT 0,
  valor_gac numeric(11,2) NOT NULL DEFAULT 0,
  porcentaje_dscto_capital numeric(11,2) NOT NULL DEFAULT 0,
  porcentaje_dscto_interes numeric(11,2) NOT NULL DEFAULT 0,
  porcentaje_dscto_intxmora numeric(11,2) NOT NULL DEFAULT 0,
  porcentaje_dscto_gac numeric(11,2) NOT NULL DEFAULT 0,
  total_neto numeric(11,2) NOT NULL DEFAULT 0,
  total numeric(11,2) NOT NULL DEFAULT 0,
  rop_generado character varying(1) NOT NULL DEFAULT 'N'::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(20) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE recaudo.facturas_rop_duplicado
  OWNER TO postgres;

