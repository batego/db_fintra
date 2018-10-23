-- Table: documentos_neg_aceptado

-- DROP TABLE documentos_neg_aceptado;

CREATE TABLE documentos_neg_aceptado
(
  cod_neg character varying(15) NOT NULL DEFAULT ''::character varying, -- codigo del negocio
  item character varying(15) NOT NULL, -- secuencia
  fecha timestamp without time zone NOT NULL, -- fecha del documento
  dias numeric(5,0) NOT NULL, -- cantidad de dias asociada al documento
  saldo_inicial moneda NOT NULL, -- saldo inicial asociado al documento
  capital moneda NOT NULL, -- capital asociado al documento
  interes moneda NOT NULL, -- interes asociado al documento
  valor moneda NOT NULL, -- valor del documento
  saldo_final moneda NOT NULL, -- saldo final asociado al documento
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  no_aval moneda DEFAULT 0,
  capacitacion moneda NOT NULL DEFAULT 0,
  cat moneda NOT NULL DEFAULT 0,
  seguro moneda NOT NULL DEFAULT 0,
  interes_causado moneda NOT NULL DEFAULT 0,
  fch_interes_causado timestamp without time zone,
  documento_cat character varying(10) NOT NULL DEFAULT ''::character varying,
  custodia numeric(10,2) DEFAULT 0,
  remesa numeric(10,2) DEFAULT 0,
  causar character varying(1) NOT NULL DEFAULT 'N'::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  tipo character varying(20) NOT NULL DEFAULT ''::character varying,
  cuota_manejo moneda DEFAULT 0,
  cuota_manejo_causada numeric(15,2) NOT NULL DEFAULT 0,
  fch_cuota_manejo_causada timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  causar_cuota_admin character varying(1) NOT NULL DEFAULT 'N'::character varying,
  procesado_mi character varying(1) NOT NULL DEFAULT 'N'::character varying, -- indica si fue enviado para la tabla de traslacion a apoteosys
  procesado_ca character varying(1) NOT NULL DEFAULT 'N'::character varying, -- indica si fue enviado para la tabla de traslacion a apoteosys
  procesado_cm character varying(1) NOT NULL DEFAULT 'N'::character varying,
  no_cheque character varying(20) NOT NULL DEFAULT ''::character varying,
  valor_aval numeric(15,2) DEFAULT 0.00
)
WITH (
  OIDS=FALSE
);
ALTER TABLE documentos_neg_aceptado
  OWNER TO postgres;
GRANT ALL ON TABLE documentos_neg_aceptado TO postgres;
GRANT SELECT ON TABLE documentos_neg_aceptado TO msoto;
COMMENT ON TABLE documentos_neg_aceptado
  IS 'cuando el negocio se acepta en el liquidador master se colocan los valores de las futuras facturas';
COMMENT ON COLUMN documentos_neg_aceptado.cod_neg IS 'codigo del negocio';
COMMENT ON COLUMN documentos_neg_aceptado.item IS 'secuencia';
COMMENT ON COLUMN documentos_neg_aceptado.fecha IS 'fecha del documento';
COMMENT ON COLUMN documentos_neg_aceptado.dias IS 'cantidad de dias asociada al documento';
COMMENT ON COLUMN documentos_neg_aceptado.saldo_inicial IS 'saldo inicial asociado al documento';
COMMENT ON COLUMN documentos_neg_aceptado.capital IS 'capital asociado al documento';
COMMENT ON COLUMN documentos_neg_aceptado.interes IS 'interes asociado al documento';
COMMENT ON COLUMN documentos_neg_aceptado.valor IS 'valor del documento';
COMMENT ON COLUMN documentos_neg_aceptado.saldo_final IS 'saldo final asociado al documento';
COMMENT ON COLUMN documentos_neg_aceptado.procesado_mi IS 'indica si fue enviado para la tabla de traslacion a apoteosys';
COMMENT ON COLUMN documentos_neg_aceptado.procesado_ca IS 'indica si fue enviado para la tabla de traslacion a apoteosys';


-- se agrega columna para guardar el valor de las polizas cuota a cuotas

 ALTER TABLE documentos_neg_aceptado ADD COLUMN capital_poliza numeric(15,2) NOT NULL DEFAULT 0;
