-- Table: remesa

-- DROP TABLE remesa;

CREATE TABLE remesa
(
  starem character(1) DEFAULT 'A'::bpchar,
  numrem character varying(10) NOT NULL DEFAULT ''::character varying, -- Remesa
  fecrem date NOT NULL DEFAULT '0099-01-01'::date, -- Fecha Despacho
  fechacargue date NOT NULL DEFAULT '0099-01-01'::date, -- Fecha Cargue
  agcrem character varying(20) NOT NULL DEFAULT ''::character varying, -- Agencia que genera la OT
  orirem character varying(20) NOT NULL DEFAULT ''::character varying, -- Origen
  desrem character varying(20) NOT NULL DEFAULT ''::character varying, -- Destino
  cliente character varying(40) NOT NULL DEFAULT ''::character varying,
  destinatario text NOT NULL DEFAULT ''::character varying, -- Destinatario
  unidcam character varying(3) NOT NULL DEFAULT 'COP'::character varying,
  docuinterno text NOT NULL DEFAULT ''::text, -- Documento Interno
  facturacial text NOT NULL DEFAULT ''::text, -- Factura Comercial
  tipoviaje character varying(2) NOT NULL DEFAULT ''::character varying, -- Tipo de Viaje
  cia character varying(4) NOT NULL DEFAULT ''::character varying,
  lastupdate timestamp without time zone NOT NULL DEFAULT now(),
  usuario character varying(10) NOT NULL DEFAULT ''::character varying,
  vlrrem numeric(15,2) NOT NULL DEFAULT 0.00,
  vlrrem2 numeric(15,2) NOT NULL DEFAULT 0.00,
  remitente character varying(40) NOT NULL DEFAULT ''::character varying, -- Remitente
  ultreporte character varying(40) NOT NULL DEFAULT ''::character varying, -- Ultimo Reporte
  observacion text NOT NULL DEFAULT ''::character varying, -- Observaciones de Entrega
  demoras character varying(2000) NOT NULL DEFAULT ''::character varying, -- Demoras
  pesoreal numeric(10,3) NOT NULL DEFAULT 0, -- Peso Real
  crossdocking character(1) NOT NULL DEFAULT 'N'::bpchar, -- Cross Docking
  estado character varying(2) NOT NULL DEFAULT ''::character varying, -- Estado de la remesa
  unit_of_work character varying(4) NOT NULL DEFAULT ''::character varying, -- unit of work
  ot_padre character varying(10) NOT NULL DEFAULT ''::character varying, -- OT Padre
  ot_rela character varying(10) NOT NULL DEFAULT ''::character varying, -- OT Relacionada
  tieneplanilla character(1) NOT NULL DEFAULT 'S'::bpchar, -- Tiene Planilla Valida
  fecremori timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Fecha de la remesa Original
  plan_str_date date NOT NULL DEFAULT '0099-01-01'::date, -- Fecha Planeada Despacho Mims
  std_job_no character varying(10) NOT NULL DEFAULT ''::character varying, -- Std_job_no de MIMS
  descripcion character varying(50) NOT NULL DEFAULT ''::character varying, -- Descripcion
  reg_status character(1) NOT NULL DEFAULT ''::bpchar, -- Estado del Registro
  printer_date timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Fecha Impresion
  derechos_cedido character varying(4) NOT NULL DEFAULT ''::character varying, -- Derechos Cedidos
  remision character varying(8) NOT NULL DEFAULT ''::character varying, -- Remision
  creation_date timestamp without time zone NOT NULL DEFAULT now(), -- Fecha de Creacion
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  codtipocarga character varying(6) DEFAULT ''::character varying,
  qty_value numeric(10,3) NOT NULL DEFAULT 0.000,
  qty_packed numeric(10,3) NOT NULL DEFAULT 0.000,
  qty_value_received numeric(10,3) NOT NULL DEFAULT 0.000,
  qty_packed_received numeric(10,3) NOT NULL DEFAULT 0.000,
  unit_packed character varying(10),
  corte timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  currency character varying(3) DEFAULT ''::character varying, -- Moneda Remesa
  n_facturable character varying(1) DEFAULT ''::character varying,
  aduana character varying(1) NOT NULL DEFAULT 'N'::character varying, -- Indica si la remesa tiene movimientos registrados en movrem
  documento character varying(10) DEFAULT ''::character varying, -- codigo factura
  transaccion integer NOT NULL DEFAULT 0, -- Indica el numero de la transaccion relacionada a la contabilidad
  fecha_contabilizacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Indica la fecha en que fue contabilizado el registro
  tipo_doc_fac character varying(5) NOT NULL DEFAULT ''::character varying, -- Indica el tipo de documento de la factura relacionada a la remesa
  doc_fac character varying(10) NOT NULL DEFAULT ''::character varying, -- Indica el numero de documento de la factura relacionada a la remesa
  periodo character varying(6) DEFAULT ''::character varying, -- Periodo de contabilizacion
  cadena character(1) DEFAULT 'N'::bpchar, -- Indica si el despacho es de cadena
  cod_pagador character varying(6) NOT NULL DEFAULT ''::character varying, -- Codigo del pagador
  cmc character varying(6) NOT NULL DEFAULT ''::character varying, -- Indica cmc del cliente
  imagen character(1) NOT NULL DEFAULT 'N'::bpchar, -- Si la remesa tiene imagen digitalizada
  despacho character(1) NOT NULL DEFAULT 'T'::bpchar, -- Agente aduanero de la remesa
  agente_aduanero character varying(30) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT chk_numrem_vacio CHECK (ltrim(numrem::text) <> ''::text)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE remesa
  OWNER TO postgres;
GRANT ALL ON TABLE remesa TO postgres;
GRANT SELECT ON TABLE remesa TO msoto;
COMMENT ON COLUMN remesa.numrem IS 'Remesa';
COMMENT ON COLUMN remesa.fecrem IS 'Fecha Despacho';
COMMENT ON COLUMN remesa.fechacargue IS 'Fecha Cargue';
COMMENT ON COLUMN remesa.agcrem IS 'Agencia que genera la OT';
COMMENT ON COLUMN remesa.orirem IS 'Origen';
COMMENT ON COLUMN remesa.desrem IS 'Destino';
COMMENT ON COLUMN remesa.destinatario IS 'Destinatario';
COMMENT ON COLUMN remesa.docuinterno IS 'Documento Interno';
COMMENT ON COLUMN remesa.facturacial IS 'Factura Comercial';
COMMENT ON COLUMN remesa.tipoviaje IS 'Tipo de Viaje';
COMMENT ON COLUMN remesa.remitente IS 'Remitente';
COMMENT ON COLUMN remesa.ultreporte IS 'Ultimo Reporte';
COMMENT ON COLUMN remesa.observacion IS 'Observaciones de Entrega';
COMMENT ON COLUMN remesa.demoras IS 'Demoras';
COMMENT ON COLUMN remesa.pesoreal IS 'Peso Real';
COMMENT ON COLUMN remesa.crossdocking IS 'Cross Docking';
COMMENT ON COLUMN remesa.estado IS 'Estado de la remesa';
COMMENT ON COLUMN remesa.unit_of_work IS 'unit of work';
COMMENT ON COLUMN remesa.ot_padre IS 'OT Padre';
COMMENT ON COLUMN remesa.ot_rela IS 'OT Relacionada';
COMMENT ON COLUMN remesa.tieneplanilla IS 'Tiene Planilla Valida';
COMMENT ON COLUMN remesa.fecremori IS 'Fecha de la remesa Original';
COMMENT ON COLUMN remesa.plan_str_date IS 'Fecha Planeada Despacho Mims';
COMMENT ON COLUMN remesa.std_job_no IS 'Std_job_no de MIMS';
COMMENT ON COLUMN remesa.descripcion IS 'Descripcion';
COMMENT ON COLUMN remesa.reg_status IS 'Estado del Registro';
COMMENT ON COLUMN remesa.printer_date IS 'Fecha Impresion';
COMMENT ON COLUMN remesa.derechos_cedido IS 'Derechos Cedidos';
COMMENT ON COLUMN remesa.remision IS 'Remision';
COMMENT ON COLUMN remesa.creation_date IS 'Fecha de Creacion';
COMMENT ON COLUMN remesa.currency IS 'Moneda Remesa';
COMMENT ON COLUMN remesa.aduana IS 'Indica si la remesa tiene movimientos registrados en movrem';
COMMENT ON COLUMN remesa.documento IS 'codigo factura';
COMMENT ON COLUMN remesa.transaccion IS 'Indica el numero de la transaccion relacionada a la contabilidad';
COMMENT ON COLUMN remesa.fecha_contabilizacion IS 'Indica la fecha en que fue contabilizado el registro';
COMMENT ON COLUMN remesa.tipo_doc_fac IS 'Indica el tipo de documento de la factura relacionada a la remesa';
COMMENT ON COLUMN remesa.doc_fac IS 'Indica el numero de documento de la factura relacionada a la remesa';
COMMENT ON COLUMN remesa.periodo IS 'Periodo de contabilizacion';
COMMENT ON COLUMN remesa.cadena IS 'Indica si el despacho es de cadena';
COMMENT ON COLUMN remesa.cod_pagador IS 'Codigo del pagador';
COMMENT ON COLUMN remesa.cmc IS 'Indica cmc del cliente';
COMMENT ON COLUMN remesa.imagen IS 'Si la remesa tiene imagen digitalizada';
COMMENT ON COLUMN remesa.despacho IS 'Agente aduanero de la remesa';


