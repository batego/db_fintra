-- Table: tblcon

-- DROP TABLE tblcon;

CREATE TABLE tblcon
(
  reg_status character(1) NOT NULL DEFAULT ''::bpchar, -- Estado del regitro
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying, -- Distrito
  concept_code character varying(6) NOT NULL DEFAULT ''::character varying, -- Codigo del Concepto
  concept_desc character varying(30) NOT NULL DEFAULT ''::character varying, -- Descripcion del concepto
  ind_application character varying(1) NOT NULL DEFAULT ''::character varying, -- Indica si es un ingreso o un costo, los valores posibles son I o C
  account character varying(25) NOT NULL DEFAULT ''::character varying, -- Codigo de cuenta contable
  last_update timestamp without time zone NOT NULL DEFAULT now(), -- Ultima modificacion
  user_update character varying(10) NOT NULL DEFAULT ''::character varying, -- Usuario que realizo la ultima modificacion
  creation_date timestamp without time zone NOT NULL DEFAULT now(), -- Fecha de creacion del registro
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying, -- Usuario de creacion del registro
  codigo_migracion character varying(5), -- Codigo de migracion
  base character varying(3) NOT NULL DEFAULT ''::character varying, -- Base
  visible character varying(1) DEFAULT 'Y'::character varying, -- Indica si el concepto es o no visible desde otra interfaz
  modif character varying(1) NOT NULL DEFAULT 'N'::character varying, -- Indica si este campo desde otra interfaz tiene mas posibilidades que los asociados a este concepto
  ind_signo numeric(1,0) NOT NULL DEFAULT 1, -- Indicador de signo, si el concepto debe ser positivo o negativo
  concept_class character varying(10) NOT NULL DEFAULT ''::character varying, -- Clase de concepto
  tipocuenta character varying(1) NOT NULL DEFAULT ''::character varying, -- Indica si el dato guardado en el campo account es cuenta (C) o elemento del gasto (E)
  asocia_cheque character varying(1) NOT NULL DEFAULT ''::character varying, -- Indica si el tipo de concepto se imprime en un cheque (S)
  tipo character varying(1) NOT NULL DEFAULT ''::character varying, -- Tipo del valor P para Porcentaje, V para Valor
  vlr moneda NOT NULL DEFAULT 0.0, -- Valor default del descuento
  currency character varying(3) NOT NULL DEFAULT ''::character varying, -- Moneda del valor
  descuento_fijo character varying(1) NOT NULL DEFAULT ''::character varying, -- Indica si es un descuento fijo con S de lo contrario N
  ingreso_costo character varying(1) NOT NULL DEFAULT 'C'::character varying,
  tipo_sub character varying(10) NOT NULL DEFAULT ''::character varying -- tipo de subledger
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tblcon
  OWNER TO postgres;
GRANT ALL ON TABLE tblcon TO postgres;
GRANT SELECT ON TABLE tblcon TO msoto;
COMMENT ON COLUMN tblcon.reg_status IS 'Estado del regitro';
COMMENT ON COLUMN tblcon.dstrct IS 'Distrito';
COMMENT ON COLUMN tblcon.concept_code IS 'Codigo del Concepto';
COMMENT ON COLUMN tblcon.concept_desc IS 'Descripcion del concepto';
COMMENT ON COLUMN tblcon.ind_application IS 'Indica si es un ingreso o un costo, los valores posibles son I o C';
COMMENT ON COLUMN tblcon.account IS 'Codigo de cuenta contable';
COMMENT ON COLUMN tblcon.last_update IS 'Ultima modificacion';
COMMENT ON COLUMN tblcon.user_update IS 'Usuario que realizo la ultima modificacion';
COMMENT ON COLUMN tblcon.creation_date IS 'Fecha de creacion del registro';
COMMENT ON COLUMN tblcon.creation_user IS 'Usuario de creacion del registro';
COMMENT ON COLUMN tblcon.codigo_migracion IS 'Codigo de migracion';
COMMENT ON COLUMN tblcon.base IS 'Base';
COMMENT ON COLUMN tblcon.visible IS 'Indica si el concepto es o no visible desde otra interfaz';
COMMENT ON COLUMN tblcon.modif IS 'Indica si este campo desde otra interfaz tiene mas posibilidades que los asociados a este concepto';
COMMENT ON COLUMN tblcon.ind_signo IS 'Indicador de signo, si el concepto debe ser positivo o negativo';
COMMENT ON COLUMN tblcon.concept_class IS 'Clase de concepto';
COMMENT ON COLUMN tblcon.tipocuenta IS 'Indica si el dato guardado en el campo account es cuenta (C) o elemento del gasto (E)';
COMMENT ON COLUMN tblcon.asocia_cheque IS 'Indica si el tipo de concepto se imprime en un cheque (S)';
COMMENT ON COLUMN tblcon.tipo IS 'Tipo del valor P para Porcentaje, V para Valor';
COMMENT ON COLUMN tblcon.vlr IS 'Valor default del descuento';
COMMENT ON COLUMN tblcon.currency IS 'Moneda del valor';
COMMENT ON COLUMN tblcon.descuento_fijo IS 'Indica si es un descuento fijo con S de lo contrario N';
COMMENT ON COLUMN tblcon.tipo_sub IS 'tipo de subledger';


