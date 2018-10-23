-- Table: captaciones

-- DROP TABLE captaciones;

CREATE TABLE captaciones
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying, -- Estado de el extracto
  dstrct character varying(15) NOT NULL DEFAULT ''::character varying, -- Distrito
  proveedor character varying(15) NOT NULL DEFAULT ''::character varying, -- id del propietario
  tipo_operacion character varying(15) NOT NULL DEFAULT ''::character varying, -- Si es una  Base o Movimiento; siempre se generauna Base despues de un Movimiento
  tipo_documento character varying(15) NOT NULL DEFAULT ''::character varying, -- 01 = Captacion 02= Liquidacion 03=Salida 04=Fin de Mes
  documento character varying(30) NOT NULL DEFAULT ''::character varying, -- Consecutivo extrayendo desde la tabla de series
  fecha_documento timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Fecha de creacion
  fecha_inicio timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Fecha desde cuando se inicia a pagar intereses
  vlr_capital moneda, -- Valor de la captacion o del valor del capital
  moneda character varying(3) NOT NULL DEFAULT ''::character varying, -- Desde un campo en tablagen
  interes numeric(18,10) NOT NULL DEFAULT 0, -- % interes que se le paga al proveedor con 3 decimales
  frecuencia character varying(30) NOT NULL DEFAULT ''::character varying, -- Diario, semanal, mensual, trimestral, semestral, anual
  clase_ingreso character varying(3) NOT NULL DEFAULT ''::character varying, -- Consignacion CO, traslado TR, cheque CH, efectivo EF definido en tablagen
  ref1 character varying(30) NOT NULL DEFAULT ''::character varying, -- Puede ser numero del cheque, de la consignacion, del traslado o un numero de recibo de caja
  ref2 character varying(30) NOT NULL DEFAULT ''::character varying, -- Puede ser banco
  ref3 character varying(30) NOT NULL DEFAULT ''::character varying, -- Puede ser sucursal
  fecha_liquidacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Fecha en que se elabora la liquidacion
  fecha_corte timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Fecha hasta la cual se paga los intereses
  vlr_intereses moneda, -- valor intereses
  vlr_retefuente moneda, -- valor retefuente
  vlr_total_capital moneda, -- valor total capital
  vlr_nuevo_capital moneda, -- valor nuevo capital
  tipo_documento_previo character varying(15) NOT NULL DEFAULT ''::character varying, -- tipo documento previo
  documento_previo character varying(30) NOT NULL DEFAULT ''::character varying, -- numero documento previo
  base character varying(3) NOT NULL DEFAULT ''::character varying, -- La Base del Movimiento
  creation_date timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Fecha de Creacion
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying, -- Usuario de Creacion
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Ultima Actualizacion
  user_update character varying(15) NOT NULL DEFAULT ''::character varying, -- Usuario Ultima Actualizacion
  cod_cuenta_contable character varying(15) NOT NULL DEFAULT ''::character varying, -- Codigo de la cuenta contable
  transaccion_id character varying(30) NOT NULL DEFAULT ''::character varying, -- Numero de la transaccion
  doc_contabilidad character varying(30) NOT NULL DEFAULT ''::character varying, -- documento de contabilidad
  fecha_contabilazo timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- fecha en al que se contabilizo
  usuario_contabilizo character varying(15) NOT NULL DEFAULT ''::character varying, -- usuario que contabilizo
  fecha_anulacion_con timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- fecha de anulacion de la contabilizacion
  usuario_anulacion_con character varying(15) NOT NULL DEFAULT ''::character varying, -- usuario que anulo la contabilizacion
  fecha_recibo_con timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- fecha en la que se recibio la contabilizacion
  usuario_recibio_con character varying(15) NOT NULL DEFAULT ''::character varying, -- usuaro que recibio la contabilizacion
  vlr_reteica moneda
)
WITH (
  OIDS=FALSE
);
ALTER TABLE captaciones
  OWNER TO postgres;
GRANT ALL ON TABLE captaciones TO postgres;
GRANT SELECT ON TABLE captaciones TO msoto;
COMMENT ON COLUMN captaciones.reg_status IS 'Estado de el extracto';
COMMENT ON COLUMN captaciones.dstrct IS 'Distrito';
COMMENT ON COLUMN captaciones.proveedor IS 'id del propietario';
COMMENT ON COLUMN captaciones.tipo_operacion IS 'Si es una  Base o Movimiento; siempre se generauna Base despues de un Movimiento';
COMMENT ON COLUMN captaciones.tipo_documento IS '01 = Captacion 02= Liquidacion 03=Salida 04=Fin de Mes';
COMMENT ON COLUMN captaciones.documento IS 'Consecutivo extrayendo desde la tabla de series';
COMMENT ON COLUMN captaciones.fecha_documento IS 'Fecha de creacion';
COMMENT ON COLUMN captaciones.fecha_inicio IS 'Fecha desde cuando se inicia a pagar intereses';
COMMENT ON COLUMN captaciones.vlr_capital IS 'Valor de la captacion o del valor del capital';
COMMENT ON COLUMN captaciones.moneda IS 'Desde un campo en tablagen';
COMMENT ON COLUMN captaciones.interes IS '% interes que se le paga al proveedor con 3 decimales';
COMMENT ON COLUMN captaciones.frecuencia IS 'Diario, semanal, mensual, trimestral, semestral, anual';
COMMENT ON COLUMN captaciones.clase_ingreso IS 'Consignacion CO, traslado TR, cheque CH, efectivo EF definido en tablagen';
COMMENT ON COLUMN captaciones.ref1 IS 'Puede ser numero del cheque, de la consignacion, del traslado o un numero de recibo de caja';
COMMENT ON COLUMN captaciones.ref2 IS 'Puede ser banco';
COMMENT ON COLUMN captaciones.ref3 IS 'Puede ser sucursal';
COMMENT ON COLUMN captaciones.fecha_liquidacion IS 'Fecha en que se elabora la liquidacion';
COMMENT ON COLUMN captaciones.fecha_corte IS 'Fecha hasta la cual se paga los intereses';
COMMENT ON COLUMN captaciones.vlr_intereses IS 'valor intereses';
COMMENT ON COLUMN captaciones.vlr_retefuente IS 'valor retefuente';
COMMENT ON COLUMN captaciones.vlr_total_capital IS 'valor total capital';
COMMENT ON COLUMN captaciones.vlr_nuevo_capital IS 'valor nuevo capital';
COMMENT ON COLUMN captaciones.tipo_documento_previo IS 'tipo documento previo';
COMMENT ON COLUMN captaciones.documento_previo IS 'numero documento previo';
COMMENT ON COLUMN captaciones.base IS 'La Base del Movimiento';
COMMENT ON COLUMN captaciones.creation_date IS 'Fecha de Creacion';
COMMENT ON COLUMN captaciones.creation_user IS 'Usuario de Creacion';
COMMENT ON COLUMN captaciones.last_update IS 'Ultima Actualizacion';
COMMENT ON COLUMN captaciones.user_update IS 'Usuario Ultima Actualizacion';
COMMENT ON COLUMN captaciones.cod_cuenta_contable IS 'Codigo de la cuenta contable';
COMMENT ON COLUMN captaciones.transaccion_id IS 'Numero de la transaccion';
COMMENT ON COLUMN captaciones.doc_contabilidad IS 'documento de contabilidad';
COMMENT ON COLUMN captaciones.fecha_contabilazo IS 'fecha en al que se contabilizo';
COMMENT ON COLUMN captaciones.usuario_contabilizo IS 'usuario que contabilizo';
COMMENT ON COLUMN captaciones.fecha_anulacion_con IS 'fecha de anulacion de la contabilizacion';
COMMENT ON COLUMN captaciones.usuario_anulacion_con IS 'usuario que anulo la contabilizacion';
COMMENT ON COLUMN captaciones.fecha_recibo_con IS 'fecha en la que se recibio la contabilizacion';
COMMENT ON COLUMN captaciones.usuario_recibio_con IS 'usuaro que recibio la contabilizacion';


