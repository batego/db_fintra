-- Table: con.comprobante

-- DROP TABLE con.comprobante;

CREATE TABLE con.comprobante
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  tipodoc character varying(5) NOT NULL DEFAULT ''::character varying, -- Tipo de comprobante contable
  numdoc character varying(30) NOT NULL DEFAULT ''::character varying, -- Numero del comprobante contable
  grupo_transaccion integer NOT NULL, -- Numero de transaccion para identificacion unica operativa
  sucursal character varying(5) NOT NULL DEFAULT ''::character varying,
  periodo character varying(6) NOT NULL DEFAULT ''::character varying, -- Periodo (AAAAMM) al cual pertenece el comprobante
  fechadoc date NOT NULL DEFAULT '0099-01-01'::date, -- Fecha del comprobante
  detalle text NOT NULL DEFAULT ''::character varying, -- Descripcion general del comprobante contable
  tercero character varying(15) NOT NULL DEFAULT ''::character varying, -- Beneficiario General del comprobante contable
  total_debito moneda, -- Total debito del comprobante. Es la suma de la columna del valor debito de la tabla comprodet para ese tipo y numero de comprobante
  total_credito moneda, -- Total credito del comprobante. Es la suma de la columna del valor credito de la tabla comprodet para ese tipo y numero de comprobante
  total_items integer DEFAULT 0, -- Suma de todos los item del comprobante contable que se encuentran en la tabla comprodet
  moneda character varying(3) NOT NULL DEFAULT ''::character varying,
  fecha_aplicacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Fecha de contabilizacion del comprobante contable
  aprobador character varying(15) NOT NULL DEFAULT ''::character varying, -- Contador o auditor que aprueba las partidas del comprobante contable
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  usuario_aplicacion character varying(10) NOT NULL DEFAULT ''::character varying, -- Usuario de aplicacion
  tipo_operacion character varying(5) NOT NULL DEFAULT ''::character varying, -- Tipo de operacion del comprobante contable
  moneda_foranea character varying(3) NOT NULL DEFAULT ''::character varying, -- Moneda Foranea del documento que se esta contabilizando
  vlr_for moneda DEFAULT 0, -- Valor Foraneo del documento que se esta contabilizando
  ref_1 character varying(30) NOT NULL DEFAULT ''::character varying, -- Referencia una
  ref_2 character varying(30) NOT NULL DEFAULT ''::character varying -- Referencia dos
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.comprobante
  OWNER TO postgres;
GRANT ALL ON TABLE con.comprobante TO postgres;
GRANT SELECT ON TABLE con.comprobante TO msoto;
COMMENT ON TABLE con.comprobante
  IS 'Tabla para almcenar la cabecera de los comprobantes contables. Un registros por comprobante';
COMMENT ON COLUMN con.comprobante.tipodoc IS 'Tipo de comprobante contable';
COMMENT ON COLUMN con.comprobante.numdoc IS 'Numero del comprobante contable';
COMMENT ON COLUMN con.comprobante.grupo_transaccion IS 'Numero de transaccion para identificacion unica operativa';
COMMENT ON COLUMN con.comprobante.periodo IS 'Periodo (AAAAMM) al cual pertenece el comprobante';
COMMENT ON COLUMN con.comprobante.fechadoc IS 'Fecha del comprobante';
COMMENT ON COLUMN con.comprobante.detalle IS 'Descripcion general del comprobante contable';
COMMENT ON COLUMN con.comprobante.tercero IS 'Beneficiario General del comprobante contable';
COMMENT ON COLUMN con.comprobante.total_debito IS 'Total debito del comprobante. Es la suma de la columna del valor debito de la tabla comprodet para ese tipo y numero de comprobante';
COMMENT ON COLUMN con.comprobante.total_credito IS 'Total credito del comprobante. Es la suma de la columna del valor credito de la tabla comprodet para ese tipo y numero de comprobante';
COMMENT ON COLUMN con.comprobante.total_items IS 'Suma de todos los item del comprobante contable que se encuentran en la tabla comprodet';
COMMENT ON COLUMN con.comprobante.fecha_aplicacion IS 'Fecha de contabilizacion del comprobante contable';
COMMENT ON COLUMN con.comprobante.aprobador IS 'Contador o auditor que aprueba las partidas del comprobante contable';
COMMENT ON COLUMN con.comprobante.usuario_aplicacion IS 'Usuario de aplicacion';
COMMENT ON COLUMN con.comprobante.tipo_operacion IS 'Tipo de operacion del comprobante contable';
COMMENT ON COLUMN con.comprobante.moneda_foranea IS 'Moneda Foranea del documento que se esta contabilizando';
COMMENT ON COLUMN con.comprobante.vlr_for IS 'Valor Foraneo del documento que se esta contabilizando';
COMMENT ON COLUMN con.comprobante.ref_1 IS 'Referencia una';
COMMENT ON COLUMN con.comprobante.ref_2 IS 'Referencia dos';


