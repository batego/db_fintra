-- Table: planilla

-- DROP TABLE planilla;

CREATE TABLE planilla
(
  stapla character(1) DEFAULT 'A'::bpchar,
  numpla character varying(10) NOT NULL DEFAULT ''::character varying,
  fecpla date NOT NULL DEFAULT '0099-01-01'::date,
  agcpla character varying(3) NOT NULL DEFAULT ''::character varying,
  oripla character varying(3) NOT NULL DEFAULT ''::character varying,
  despla character varying(3) NOT NULL DEFAULT ''::character varying,
  plaveh character varying(7) NOT NULL DEFAULT ''::character varying,
  cedcon character varying(12) NOT NULL DEFAULT ''::character varying,
  nitpro character varying(12) NOT NULL DEFAULT ''::character varying,
  platlr character varying(12) NOT NULL DEFAULT ''::character varying,
  fecdsp timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  segpla numeric(5,2) NOT NULL DEFAULT 0.00,
  retpla numeric(5,2) NOT NULL DEFAULT 0.00,
  unidcam character varying(3) NOT NULL DEFAULT 'COP'::character varying,
  cia character varying(3) NOT NULL DEFAULT 'TSP'::character varying,
  tipoviaje character varying(3) NOT NULL DEFAULT ''::character varying,
  fechaposllegada timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  ultimoreporte text NOT NULL DEFAULT ''::text,
  tiempoentransito numeric(10,6) NOT NULL DEFAULT 0.00,
  pesoreal numeric(10,3) NOT NULL DEFAULT 0,
  vlrpla numeric(15,2) NOT NULL DEFAULT 0.00,
  vlrpla2 numeric(15,2) NOT NULL DEFAULT 0.00,
  nomcon character varying(40) NOT NULL DEFAULT ''::character varying, -- Nombre del Conductor
  orinom character varying(20) NOT NULL DEFAULT ''::character varying, -- Ciudad Origen
  desnom character varying(20) NOT NULL DEFAULT ''::character varying, -- Ciudad Destino
  celularcon character varying(20) NOT NULL DEFAULT ''::character varying, -- Celular del Conductor
  observacion character varying(40) NOT NULL DEFAULT ''::character varying, -- Observacion Trafico
  tienedevol character(1) NOT NULL DEFAULT 'N'::bpchar, -- Tiene Devoluciones
  status_220 character(1) NOT NULL DEFAULT ''::bpchar, -- status_220
  despachador character varying(10) NOT NULL DEFAULT ''::character varying, -- Despachador (creation_user de la MSF220)
  ruta_pla text, -- Ruta de la Planilla
  orden_carga character varying(10),
  creation_date timestamp without time zone,
  printer_date timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Fecha de Impresion de la planilla
  precinto text NOT NULL DEFAULT ''::text, -- Precinto
  reg_status character(1) NOT NULL DEFAULT ''::bpchar, -- Estado del Registro
  feccum timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Fecha de Cumplido
  group_code character(8) NOT NULL DEFAULT ''::bpchar, -- Codigo Grupo
  unit_vlr character varying(7) NOT NULL DEFAULT ''::character varying, -- Unidad de Valorizacion
  currency character varying(4) NOT NULL DEFAULT ''::character varying, -- Moneda
  unit_cost numeric(15,2) NOT NULL DEFAULT 0.0, -- Unidad Costo
  last_update timestamp without time zone NOT NULL DEFAULT now(), -- Fecha de Actualizacion
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  corte timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  contenedores text,
  tipocont character varying(3),
  tipotrailer character varying(3),
  proveedor character varying(12) DEFAULT ''::character varying, -- Proveedor
  fechasalidatraf timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Fecha/Hora informe de Salida de Trafico
  cod_actividad character varying(6) DEFAULT ''::character varying,
  factura character varying(30) NOT NULL DEFAULT ''::character varying,
  cf_code character varying(8) NOT NULL DEFAULT ''::character varying, -- Codigo de la +CF Utilizada
  tiene_doc character varying(1) DEFAULT ''::character varying, -- Identifica si tiene documentos
  orden character varying(12) DEFAULT ''::character varying,
  transaccion integer NOT NULL DEFAULT 0, -- Indica el numero de la transaccion relacionada a la contabilidad
  fecha_contabilizacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Indica la fecha en que fue contabilizado el registro
  planeacion_frontera character varying(1) NOT NULL DEFAULT 'N'::character varying, -- Indica si esta habilitada para planeacion por frontera (S/N)
  periodo character varying(6) NOT NULL DEFAULT ''::character varying, -- Periodo
  cmc character varying(6) DEFAULT ''::character varying, -- Indica el cmc del proveedor
  caleta character varying(1) NOT NULL DEFAULT 'N'::character varying, -- Si se le ha aplicado ajuste por caleta a la planilla
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT chk_numpla_vacio CHECK (ltrim(numpla::text) <> ''::text)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE planilla
  OWNER TO postgres;
GRANT ALL ON TABLE planilla TO postgres;
GRANT SELECT ON TABLE planilla TO msoto;
COMMENT ON TABLE planilla
  IS 'Remesa - Planilla';
COMMENT ON COLUMN planilla.nomcon IS 'Nombre del Conductor';
COMMENT ON COLUMN planilla.orinom IS 'Ciudad Origen';
COMMENT ON COLUMN planilla.desnom IS 'Ciudad Destino';
COMMENT ON COLUMN planilla.celularcon IS 'Celular del Conductor';
COMMENT ON COLUMN planilla.observacion IS 'Observacion Trafico';
COMMENT ON COLUMN planilla.tienedevol IS 'Tiene Devoluciones';
COMMENT ON COLUMN planilla.status_220 IS 'status_220';
COMMENT ON COLUMN planilla.despachador IS 'Despachador (creation_user de la MSF220)';
COMMENT ON COLUMN planilla.ruta_pla IS 'Ruta de la Planilla';
COMMENT ON COLUMN planilla.printer_date IS 'Fecha de Impresion de la planilla';
COMMENT ON COLUMN planilla.precinto IS 'Precinto';
COMMENT ON COLUMN planilla.reg_status IS 'Estado del Registro';
COMMENT ON COLUMN planilla.feccum IS 'Fecha de Cumplido';
COMMENT ON COLUMN planilla.group_code IS 'Codigo Grupo';
COMMENT ON COLUMN planilla.unit_vlr IS 'Unidad de Valorizacion';
COMMENT ON COLUMN planilla.currency IS 'Moneda';
COMMENT ON COLUMN planilla.unit_cost IS 'Unidad Costo';
COMMENT ON COLUMN planilla.last_update IS 'Fecha de Actualizacion';
COMMENT ON COLUMN planilla.proveedor IS 'Proveedor';
COMMENT ON COLUMN planilla.fechasalidatraf IS 'Fecha/Hora informe de Salida de Trafico';
COMMENT ON COLUMN planilla.cf_code IS 'Codigo de la +CF Utilizada';
COMMENT ON COLUMN planilla.tiene_doc IS 'Identifica si tiene documentos';
COMMENT ON COLUMN planilla.transaccion IS 'Indica el numero de la transaccion relacionada a la contabilidad';
COMMENT ON COLUMN planilla.fecha_contabilizacion IS 'Indica la fecha en que fue contabilizado el registro';
COMMENT ON COLUMN planilla.planeacion_frontera IS 'Indica si esta habilitada para planeacion por frontera (S/N)';
COMMENT ON COLUMN planilla.periodo IS 'Periodo';
COMMENT ON COLUMN planilla.cmc IS 'Indica el cmc del proveedor';
COMMENT ON COLUMN planilla.caleta IS 'Si se le ha aplicado ajuste por caleta a la planilla';


