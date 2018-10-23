-- Table: recaudo.consolidado_rop_duplicado

-- DROP TABLE recaudo.consolidado_rop_duplicado;

CREATE TABLE recaudo.consolidado_rop_duplicado
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(8) NOT NULL DEFAULT 'FINV'::character varying,
  codigo_duplicado character varying(15) NOT NULL DEFAULT ''::character varying,
  estado_cartera character varying(20) NOT NULL DEFAULT ''::character varying,
  porcentaje_dscto_capital numeric(11,2) NOT NULL DEFAULT 0,
  porcentaje_dscto_interes numeric(11,2) NOT NULL DEFAULT 0,
  porcentaje_dscto_intxmora numeric(11,2) NOT NULL DEFAULT 0,
  porcentaje_dscto_gac numeric(11,2) NOT NULL DEFAULT 0,
  valor_neto_rop numeric(11,2) NOT NULL DEFAULT 0,
  valor_capital_rop numeric(11,2) NOT NULL DEFAULT 0,
  valor_interes_rop numeric(11,2) NOT NULL DEFAULT 0,
  valor_mora_rop numeric(11,2) NOT NULL DEFAULT 0,
  valor_gac_rop numeric(11,2) NOT NULL DEFAULT 0,
  total numeric(11,2) NOT NULL DEFAULT 0,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(20) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE recaudo.consolidado_rop_duplicado
  OWNER TO postgres;

