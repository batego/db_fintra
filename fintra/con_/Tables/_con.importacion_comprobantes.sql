-- Table: con.importacion_comprobantes

-- DROP TABLE con.importacion_comprobantes;

CREATE TABLE con.importacion_comprobantes
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying, -- Estado del Registro
  dstrct character varying(5) NOT NULL DEFAULT ''::character varying, -- Distrito del comprobante
  tipo_documento character varying(5) NOT NULL DEFAULT ''::character varying, -- Tipo de comprobante
  documento character varying(30) NOT NULL DEFAULT ''::character varying, -- Numero del comprobante
  descripcion text NOT NULL DEFAULT ''::text, -- Descripcion del comprobante
  tercero character varying(15) NOT NULL DEFAULT ''::character varying, -- Nit del tercero
  periodo character varying(6) NOT NULL DEFAULT ''::character varying, -- Periodo Contable
  fecha_documento date NOT NULL DEFAULT '0099-01-01'::date, -- Fecha del Comprobante
  total_debito moneda, -- Sumatoria de los debitos del comprobante
  total_credito moneda, -- Sumatoria de los creditos del comprobante
  moneda character varying(3) NOT NULL DEFAULT ''::character varying, -- Moneda del comprobante, segun la moneda del distrito
  sucursal character varying(5) NOT NULL DEFAULT ''::character varying, -- Agencia del usuario que genera el comprobante de importacion
  tipo_operacion character varying(5) NOT NULL DEFAULT ''::character varying, -- Tipo de operacion relacionado al comprobante
  creation_date timestamp without time zone NOT NULL DEFAULT now(), -- Fecha de Creacion
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying, -- Usuario de creacion
  base character varying(3) NOT NULL DEFAULT ''::character varying, -- Base del del comprobante
  item character varying(4) NOT NULL DEFAULT ''::character varying, -- Nuemro del Item
  cuenta character varying(25) NOT NULL DEFAULT ''::character varying, -- Codigo de cuenta contable
  tipo_auxiliar character varying(25) NOT NULL DEFAULT ''::character varying,
  auxiliar character varying(25) NOT NULL DEFAULT ''::character varying,
  descripcion_item text NOT NULL DEFAULT ''::text,
  debito moneda, -- Debito del item del comprobante
  credito moneda, -- Credito del item del comprobante
  tercero_item character varying(15) NOT NULL DEFAULT ''::character varying, -- Tercero asociado al item del comprobante
  tdoc_rel character varying(5) NOT NULL DEFAULT ''::character varying, -- Tipo de documento relacionado
  doc_rel character varying(15) NOT NULL DEFAULT ''::character varying, -- Documento Relacionado
  abc character varying(4) NOT NULL DEFAULT ''::character varying, -- Codigo ABC
  total_foraneo moneda NOT NULL DEFAULT 0,
  valor_foraneo moneda NOT NULL DEFAULT 0
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.importacion_comprobantes
  OWNER TO postgres;
GRANT ALL ON TABLE con.importacion_comprobantes TO postgres;
GRANT SELECT ON TABLE con.importacion_comprobantes TO msoto;
COMMENT ON COLUMN con.importacion_comprobantes.reg_status IS 'Estado del Registro';
COMMENT ON COLUMN con.importacion_comprobantes.dstrct IS 'Distrito del comprobante';
COMMENT ON COLUMN con.importacion_comprobantes.tipo_documento IS 'Tipo de comprobante';
COMMENT ON COLUMN con.importacion_comprobantes.documento IS 'Numero del comprobante';
COMMENT ON COLUMN con.importacion_comprobantes.descripcion IS 'Descripcion del comprobante';
COMMENT ON COLUMN con.importacion_comprobantes.tercero IS 'Nit del tercero';
COMMENT ON COLUMN con.importacion_comprobantes.periodo IS 'Periodo Contable';
COMMENT ON COLUMN con.importacion_comprobantes.fecha_documento IS 'Fecha del Comprobante';
COMMENT ON COLUMN con.importacion_comprobantes.total_debito IS 'Sumatoria de los debitos del comprobante';
COMMENT ON COLUMN con.importacion_comprobantes.total_credito IS 'Sumatoria de los creditos del comprobante';
COMMENT ON COLUMN con.importacion_comprobantes.moneda IS 'Moneda del comprobante, segun la moneda del distrito';
COMMENT ON COLUMN con.importacion_comprobantes.sucursal IS 'Agencia del usuario que genera el comprobante de importacion';
COMMENT ON COLUMN con.importacion_comprobantes.tipo_operacion IS 'Tipo de operacion relacionado al comprobante';
COMMENT ON COLUMN con.importacion_comprobantes.creation_date IS 'Fecha de Creacion';
COMMENT ON COLUMN con.importacion_comprobantes.creation_user IS 'Usuario de creacion';
COMMENT ON COLUMN con.importacion_comprobantes.base IS 'Base del del comprobante';
COMMENT ON COLUMN con.importacion_comprobantes.item IS 'Nuemro del Item';
COMMENT ON COLUMN con.importacion_comprobantes.cuenta IS 'Codigo de cuenta contable';
COMMENT ON COLUMN con.importacion_comprobantes.debito IS 'Debito del item del comprobante';
COMMENT ON COLUMN con.importacion_comprobantes.credito IS 'Credito del item del comprobante';
COMMENT ON COLUMN con.importacion_comprobantes.tercero_item IS 'Tercero asociado al item del comprobante';
COMMENT ON COLUMN con.importacion_comprobantes.tdoc_rel IS 'Tipo de documento relacionado';
COMMENT ON COLUMN con.importacion_comprobantes.doc_rel IS 'Documento Relacionado';
COMMENT ON COLUMN con.importacion_comprobantes.abc IS 'Codigo ABC';


