-- Table: con.comprodet

-- DROP TABLE con.comprodet;

CREATE TABLE con.comprodet
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  tipodoc character varying(5) NOT NULL DEFAULT ''::character varying, -- Tipo de documento relacionado
  numdoc character varying(30) NOT NULL DEFAULT ''::character varying, -- Numero del comprobante contable
  grupo_transaccion integer NOT NULL DEFAULT 0, -- Numero de transaccion para identificacion unica operativa
  transaccion serial NOT NULL, -- Consecutivo unico que identifica y diferencia las partidas contables dentro de un mismo comprobante
  periodo character varying(6) NOT NULL DEFAULT ''::character varying, -- periodo al que pertenece la partida del comprobante contable
  cuenta character varying(25) NOT NULL DEFAULT ''::character varying, -- Codigo Contable
  auxiliar character varying(25) NOT NULL DEFAULT ''::character varying, -- Codigo contable auxiliar o Sublegers
  detalle text NOT NULL DEFAULT ''::character varying, -- Descripcion de la partida contable
  valor_debito moneda, -- Valor debito
  valor_credito moneda, -- Valor Credito
  tercero character varying(15) NOT NULL DEFAULT ''::character varying, -- Nit del beneficiario al que debe afectar la partida
  documento_interno character varying(30) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  tipodoc_rel character varying(5) NOT NULL DEFAULT ''::character varying,
  documento_rel character varying(30) NOT NULL DEFAULT ''::character varying, -- Numero de documento relacionado
  abc character varying(4) NOT NULL DEFAULT ''::character varying, -- Centro de Actividad y Area
  vlr_for moneda DEFAULT 0, -- Valor Foraneo del item del documento que se esta contabilizando
  tipo_referencia_1 character varying(5) NOT NULL DEFAULT ''::character varying,
  referencia_1 character varying(30) NOT NULL DEFAULT ''::character varying,
  tipo_referencia_2 character varying(5) NOT NULL DEFAULT ''::character varying,
  referencia_2 character varying(30) NOT NULL DEFAULT ''::character varying,
  tipo_referencia_3 character varying(5) NOT NULL DEFAULT ''::character varying,
  referencia_3 character varying(50) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.comprodet
  OWNER TO postgres;
GRANT ALL ON TABLE con.comprodet TO postgres;
GRANT SELECT ON TABLE con.comprodet TO msoto;
COMMENT ON TABLE con.comprodet
  IS 'Tabla para almacenar el detalle de los comprobantes contables. Como restriccion debe primero tener un registros en la tabla "comprobante"';
COMMENT ON COLUMN con.comprodet.tipodoc IS 'Tipo de documento relacionado';
COMMENT ON COLUMN con.comprodet.numdoc IS 'Numero del comprobante contable';
COMMENT ON COLUMN con.comprodet.grupo_transaccion IS 'Numero de transaccion para identificacion unica operativa';
COMMENT ON COLUMN con.comprodet.transaccion IS 'Consecutivo unico que identifica y diferencia las partidas contables dentro de un mismo comprobante';
COMMENT ON COLUMN con.comprodet.periodo IS 'periodo al que pertenece la partida del comprobante contable';
COMMENT ON COLUMN con.comprodet.cuenta IS 'Codigo Contable';
COMMENT ON COLUMN con.comprodet.auxiliar IS 'Codigo contable auxiliar o Sublegers';
COMMENT ON COLUMN con.comprodet.detalle IS 'Descripcion de la partida contable';
COMMENT ON COLUMN con.comprodet.valor_debito IS 'Valor debito';
COMMENT ON COLUMN con.comprodet.valor_credito IS 'Valor Credito';
COMMENT ON COLUMN con.comprodet.tercero IS 'Nit del beneficiario al que debe afectar la partida';
COMMENT ON COLUMN con.comprodet.documento_rel IS 'Numero de documento relacionado';
COMMENT ON COLUMN con.comprodet.abc IS 'Centro de Actividad y Area';
COMMENT ON COLUMN con.comprodet.vlr_for IS 'Valor Foraneo del item del documento que se esta contabilizando';


