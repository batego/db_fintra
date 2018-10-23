-- Table: fin.extracto_tsp

-- DROP TABLE fin.extracto_tsp;

CREATE TABLE fin.extracto_tsp
(
  reg_status character varying(1) DEFAULT ''::character varying, -- Estado de el extracto
  dstrct character varying(15) NOT NULL DEFAULT ''::character varying, -- Distrito
  nit character varying(15) NOT NULL DEFAULT ''::character varying, -- nit del propietario
  fecha timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- fecha de creacion de archivo
  vlr_pp moneda NOT NULL DEFAULT 0, -- valor del prontopago
  vlr_ppa moneda NOT NULL DEFAULT 0, -- valor por el cual se autorizo el pronto pago
  currency character varying(15) NOT NULL DEFAULT ''::character varying, -- moneda
  banco character varying(30) NOT NULL DEFAULT ''::character varying, -- banco al que se consigna
  sucursal character varying(30) NOT NULL DEFAULT ''::character varying, -- sucursal del banco al que se consigna
  usuario_aprobacion character varying(40) NOT NULL DEFAULT ''::character varying, -- usuario que aprobo
  fecha_aprobacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- fecha en que se aprobo
  nombre_trans character varying(60) NOT NULL DEFAULT ''::character varying, -- persona que aprueba la transaccion
  creation_user character varying(40) NOT NULL DEFAULT ''::character varying, -- usuario que lo creo
  creation_date timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- fecha de creacion
  user_update character varying(40) NOT NULL DEFAULT ''::character varying, -- fecha de actualizacion
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- ultima actualizacion
  base character varying(15) NOT NULL DEFAULT ''::character varying, -- base
  secuencia serial NOT NULL, -- secuencia de extracto detalle
  fecha_envio_ws timestamp without time zone,
  fecha_anulacion timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  creation_date_real timestamp without time zone,
  pk_novedad integer
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fin.extracto_tsp
  OWNER TO postgres;
COMMENT ON TABLE fin.extracto_tsp
  IS 'Observaciones de Aprobacion de Items';
COMMENT ON COLUMN fin.extracto_tsp.reg_status IS 'Estado de el extracto';
COMMENT ON COLUMN fin.extracto_tsp.dstrct IS 'Distrito';
COMMENT ON COLUMN fin.extracto_tsp.nit IS 'nit del propietario';
COMMENT ON COLUMN fin.extracto_tsp.fecha IS 'fecha de creacion de archivo';
COMMENT ON COLUMN fin.extracto_tsp.vlr_pp IS 'valor del prontopago';
COMMENT ON COLUMN fin.extracto_tsp.vlr_ppa IS 'valor por el cual se autorizo el pronto pago';
COMMENT ON COLUMN fin.extracto_tsp.currency IS 'moneda';
COMMENT ON COLUMN fin.extracto_tsp.banco IS 'banco al que se consigna';
COMMENT ON COLUMN fin.extracto_tsp.sucursal IS 'sucursal del banco al que se consigna';
COMMENT ON COLUMN fin.extracto_tsp.usuario_aprobacion IS 'usuario que aprobo';
COMMENT ON COLUMN fin.extracto_tsp.fecha_aprobacion IS 'fecha en que se aprobo';
COMMENT ON COLUMN fin.extracto_tsp.nombre_trans IS 'persona que aprueba la transaccion';
COMMENT ON COLUMN fin.extracto_tsp.creation_user IS 'usuario que lo creo';
COMMENT ON COLUMN fin.extracto_tsp.creation_date IS 'fecha de creacion';
COMMENT ON COLUMN fin.extracto_tsp.user_update IS 'fecha de actualizacion';
COMMENT ON COLUMN fin.extracto_tsp.last_update IS 'ultima actualizacion';
COMMENT ON COLUMN fin.extracto_tsp.base IS 'base';
COMMENT ON COLUMN fin.extracto_tsp.secuencia IS 'secuencia de extracto detalle';


-- Trigger: tinsert_other_bd on fin.extracto_tsp

-- DROP TRIGGER tinsert_other_bd ON fin.extracto_tsp;

CREATE TRIGGER tinsert_other_bd
  AFTER INSERT
  ON fin.extracto_tsp
  FOR EACH ROW
  EXECUTE PROCEDURE insert_other_bd_extracto();
ALTER TABLE fin.extracto_tsp DISABLE TRIGGER tinsert_other_bd;

-- Trigger: ttablaextractotspaextracto on fin.extracto_tsp

-- DROP TRIGGER ttablaextractotspaextracto ON fin.extracto_tsp;

CREATE TRIGGER ttablaextractotspaextracto
  AFTER INSERT
  ON fin.extracto_tsp
  FOR EACH ROW
  EXECUTE PROCEDURE tablaextractotspaextracto();


