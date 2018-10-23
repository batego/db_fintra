-- Table: fin.extracto_detalle

-- DROP TABLE fin.extracto_detalle;

CREATE TABLE fin.extracto_detalle
(
  reg_status character varying(1) DEFAULT ''::character varying, -- Estado del detalle
  dstrct character varying(15) NOT NULL DEFAULT ''::character varying, -- distrito
  nit character varying(15) DEFAULT ''::character varying, -- nit del propietario
  fecha timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- fecha de vcreacion del documento
  tipo_documento character varying(2) NOT NULL DEFAULT ''::character varying, -- tipo de documennto PK PL CC
  documento character varying(20) NOT NULL DEFAULT ''::character varying, -- numero de documento OC Placa Cedula
  concepto character varying(5) NOT NULL DEFAULT ''::character varying, -- concepto de detalle
  descripcion text NOT NULL DEFAULT ''::character varying, -- descripcion detalle
  factura character varying(40) NOT NULL DEFAULT ''::character varying, -- numero factura
  vlr moneda NOT NULL DEFAULT 0, -- valor de prontpago OC
  retefuente moneda NOT NULL DEFAULT 0, -- retencion en la fuente
  reteica moneda NOT NULL DEFAULT 0, -- reteica
  impuestos moneda NOT NULL DEFAULT 0, -- impuestos
  vlr_pp_item moneda NOT NULL DEFAULT 0, -- valor prontopago item
  vlr_ppa_item moneda NOT NULL DEFAULT 0, -- valor prontopago asignado item
  creation_user character varying(40) NOT NULL DEFAULT ''::character varying, -- usuario que creo
  creation_date timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- fecha de creacion
  user_update character varying(40) NOT NULL DEFAULT ''::character varying, -- actualizacion
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- ultima actualizacion
  base character varying(15) NOT NULL DEFAULT ''::character varying, -- base
  secuencia integer,
  placa character varying(12) NOT NULL, -- Placa de la oc
  num serial NOT NULL, -- Consecutivo unico que identifica y diferencia los registros de fin.extracto_detalle
  fecha_envio_ws timestamp without time zone,
  creation_date_real timestamp without time zone,
  pk_novedad integer,
  tipo_operacion character varying(20) NOT NULL DEFAULT ''::character varying,
  numero_operacion character varying(20) NOT NULL DEFAULT ''::character varying,
  exvlr_ppa_item moneda, -- valor prontopago asignado item
  exvlr moneda DEFAULT 0,
  exretefuente moneda DEFAULT 0,
  exreteica moneda DEFAULT 0,
  exnit character varying(15),
  ruta character varying(200) DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fin.extracto_detalle
  OWNER TO postgres;
COMMENT ON COLUMN fin.extracto_detalle.reg_status IS 'Estado del detalle';
COMMENT ON COLUMN fin.extracto_detalle.dstrct IS 'distrito';
COMMENT ON COLUMN fin.extracto_detalle.nit IS 'nit del propietario';
COMMENT ON COLUMN fin.extracto_detalle.fecha IS 'fecha de vcreacion del documento';
COMMENT ON COLUMN fin.extracto_detalle.tipo_documento IS 'tipo de documennto PK PL CC';
COMMENT ON COLUMN fin.extracto_detalle.documento IS 'numero de documento OC Placa Cedula';
COMMENT ON COLUMN fin.extracto_detalle.concepto IS 'concepto de detalle';
COMMENT ON COLUMN fin.extracto_detalle.descripcion IS 'descripcion detalle';
COMMENT ON COLUMN fin.extracto_detalle.factura IS 'numero factura';
COMMENT ON COLUMN fin.extracto_detalle.vlr IS 'valor de prontpago OC';
COMMENT ON COLUMN fin.extracto_detalle.retefuente IS 'retencion en la fuente';
COMMENT ON COLUMN fin.extracto_detalle.reteica IS 'reteica';
COMMENT ON COLUMN fin.extracto_detalle.impuestos IS 'impuestos';
COMMENT ON COLUMN fin.extracto_detalle.vlr_pp_item IS 'valor prontopago item';
COMMENT ON COLUMN fin.extracto_detalle.vlr_ppa_item IS 'valor prontopago asignado item';
COMMENT ON COLUMN fin.extracto_detalle.creation_user IS 'usuario que creo';
COMMENT ON COLUMN fin.extracto_detalle.creation_date IS 'fecha de creacion';
COMMENT ON COLUMN fin.extracto_detalle.user_update IS 'actualizacion';
COMMENT ON COLUMN fin.extracto_detalle.last_update IS 'ultima actualizacion';
COMMENT ON COLUMN fin.extracto_detalle.base IS 'base';
COMMENT ON COLUMN fin.extracto_detalle.placa IS 'Placa de la oc';
COMMENT ON COLUMN fin.extracto_detalle.num IS 'Consecutivo unico que identifica y diferencia los registros de fin.extracto_detalle';
COMMENT ON COLUMN fin.extracto_detalle.exvlr_ppa_item IS 'valor prontopago asignado item';


