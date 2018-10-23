-- Table: fin.extracto_detalle_tsp

-- DROP TABLE fin.extracto_detalle_tsp;

CREATE TABLE fin.extracto_detalle_tsp
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
  num integer NOT NULL, -- Consecutivo unico que identifica y diferencia los registros de fin.extracto_detalle
  fecha_envio_ws timestamp without time zone,
  creation_date_real timestamp without time zone,
  pk_novedad integer,
  ruta character varying(200) DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fin.extracto_detalle_tsp
  OWNER TO postgres;
GRANT ALL ON TABLE fin.extracto_detalle_tsp TO postgres;
GRANT SELECT ON TABLE fin.extracto_detalle_tsp TO consulta;
GRANT SELECT ON TABLE fin.extracto_detalle_tsp TO consulta2;
COMMENT ON COLUMN fin.extracto_detalle_tsp.reg_status IS 'Estado del detalle';
COMMENT ON COLUMN fin.extracto_detalle_tsp.dstrct IS 'distrito';
COMMENT ON COLUMN fin.extracto_detalle_tsp.nit IS 'nit del propietario';
COMMENT ON COLUMN fin.extracto_detalle_tsp.fecha IS 'fecha de vcreacion del documento';
COMMENT ON COLUMN fin.extracto_detalle_tsp.tipo_documento IS 'tipo de documennto PK PL CC';
COMMENT ON COLUMN fin.extracto_detalle_tsp.documento IS 'numero de documento OC Placa Cedula';
COMMENT ON COLUMN fin.extracto_detalle_tsp.concepto IS 'concepto de detalle';
COMMENT ON COLUMN fin.extracto_detalle_tsp.descripcion IS 'descripcion detalle';
COMMENT ON COLUMN fin.extracto_detalle_tsp.factura IS 'numero factura';
COMMENT ON COLUMN fin.extracto_detalle_tsp.vlr IS 'valor de prontpago OC';
COMMENT ON COLUMN fin.extracto_detalle_tsp.retefuente IS 'retencion en la fuente';
COMMENT ON COLUMN fin.extracto_detalle_tsp.reteica IS 'reteica';
COMMENT ON COLUMN fin.extracto_detalle_tsp.impuestos IS 'impuestos';
COMMENT ON COLUMN fin.extracto_detalle_tsp.vlr_pp_item IS 'valor prontopago item';
COMMENT ON COLUMN fin.extracto_detalle_tsp.vlr_ppa_item IS 'valor prontopago asignado item';
COMMENT ON COLUMN fin.extracto_detalle_tsp.creation_user IS 'usuario que creo';
COMMENT ON COLUMN fin.extracto_detalle_tsp.creation_date IS 'fecha de creacion';
COMMENT ON COLUMN fin.extracto_detalle_tsp.user_update IS 'actualizacion';
COMMENT ON COLUMN fin.extracto_detalle_tsp.last_update IS 'ultima actualizacion';
COMMENT ON COLUMN fin.extracto_detalle_tsp.base IS 'base';
COMMENT ON COLUMN fin.extracto_detalle_tsp.placa IS 'Placa de la oc';
COMMENT ON COLUMN fin.extracto_detalle_tsp.num IS 'Consecutivo unico que identifica y diferencia los registros de fin.extracto_detalle';


-- Trigger: tinsert_other_bd on fin.extracto_detalle_tsp

-- DROP TRIGGER tinsert_other_bd ON fin.extracto_detalle_tsp;

CREATE TRIGGER tinsert_other_bd
  AFTER INSERT
  ON fin.extracto_detalle_tsp
  FOR EACH ROW
  EXECUTE PROCEDURE insert_other_bd_extracto_detalle();
ALTER TABLE fin.extracto_detalle_tsp DISABLE TRIGGER tinsert_other_bd;

-- Trigger: ttablaextractodettspaextracto on fin.extracto_detalle_tsp

-- DROP TRIGGER ttablaextractodettspaextracto ON fin.extracto_detalle_tsp;

CREATE TRIGGER ttablaextractodettspaextracto
  AFTER INSERT
  ON fin.extracto_detalle_tsp
  FOR EACH ROW
  EXECUTE PROCEDURE tablaextractodettspaextracto();


