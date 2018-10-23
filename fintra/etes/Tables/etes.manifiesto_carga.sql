-- Table: etes.manifiesto_carga

-- DROP TABLE etes.manifiesto_carga;

CREATE TABLE etes.manifiesto_carga
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  periodo character varying(6) NOT NULL DEFAULT ''::character varying,
  id_agencia integer NOT NULL,
  id_vehiculo integer NOT NULL,
  id_conductor integer NOT NULL,
  id_intermediario integer NOT NULL,
  id_proserv integer NOT NULL,
  planilla character varying(20) NOT NULL DEFAULT ''::character varying,
  origen character varying(80) NOT NULL DEFAULT ''::character varying,
  destino character varying(80) NOT NULL DEFAULT ''::character varying,
  fecha_creacion_anticipo timestamp without time zone NOT NULL,
  fecha_envio_fintra timestamp without time zone NOT NULL,
  valor_planilla numeric(11,2) NOT NULL DEFAULT 0,
  valor_neto_anticipo numeric(11,2) NOT NULL DEFAULT 0,
  valor_descuentos_fintra numeric(11,2) NOT NULL DEFAULT 0,
  porc_comision_intermediario numeric NOT NULL DEFAULT 0,
  valor_comision_intermediario numeric NOT NULL DEFAULT 0,
  valor_desembolsar numeric NOT NULL DEFAULT 0,
  fecha_contabilizacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  periodo_contabilizacion character varying(6) NOT NULL DEFAULT ''::character varying,
  fecha_anulacion_contabilizacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  periodo_anulacion_contabilizacion character varying(6) NOT NULL DEFAULT ''::character varying,
  transaccion integer NOT NULL DEFAULT 0,
  transaccion_anulacion integer NOT NULL DEFAULT 0,
  aprobado character varying(1) NOT NULL DEFAULT 'N'::character varying,
  fecha_aprobacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  usuario_anulacion character varying(10) NOT NULL DEFAULT ''::character varying,
  fecha_anulacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  enviado_eds character varying(1) NOT NULL DEFAULT 'N'::character varying,
  fecha_envio_eds timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  transferido character varying(1) NOT NULL DEFAULT 'N'::character varying,
  fecha_transferencia timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  numero_egreso character varying(20) NOT NULL DEFAULT ''::character varying,
  valor_egreso numeric(11,2) NOT NULL DEFAULT 0,
  reanticipo character varying(1) NOT NULL DEFAULT 'N'::character varying,
  usuario_aprobacion character varying(20) NOT NULL DEFAULT ''::character varying,
  fecha_pago_fintra timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  documento_cxp character varying(50) NOT NULL DEFAULT ''::character varying,
  fecha_corrida timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  cxc_corrida character varying(50) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  banco character varying(100) NOT NULL DEFAULT ''::character varying,
  sucursal character varying(100) NOT NULL DEFAULT ''::character varying,
  cedula_titular_cuenta character varying(100) NOT NULL DEFAULT ''::character varying,
  nombre_titular_cuenta character varying(200) NOT NULL DEFAULT ''::character varying,
  tipo_cuenta character varying(50) NOT NULL DEFAULT ''::character varying,
  no_cuenta character varying(100) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_manifiestocarga_agencia FOREIGN KEY (id_agencia)
      REFERENCES etes.agencias (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_manifiestocarga_conductor FOREIGN KEY (id_conductor)
      REFERENCES etes.conductor (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_manifiestocarga_idproserv FOREIGN KEY (id_proserv)
      REFERENCES etes.productos_servicios_transp (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_manifiestocarga_intermediario FOREIGN KEY (id_intermediario)
      REFERENCES etes.intermediario (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_manifiestocarga_vehiculo FOREIGN KEY (id_vehiculo)
      REFERENCES etes.vehiculo (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT manifiesto_carga_destino_check CHECK (destino::text <> ''::text AND destino::text <> ' '::text AND destino::text <> '  '::text),
  CONSTRAINT manifiesto_carga_origen_check CHECK (origen::text <> ''::text AND origen::text <> ' '::text AND origen::text <> '  '::text),
  CONSTRAINT manifiesto_carga_planilla_check CHECK (planilla::text <> ''::text AND planilla::text <> ' '::text AND planilla::text <> '  '::text)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE etes.manifiesto_carga
  OWNER TO postgres;

-- Trigger: anular_cxp_transferencia on etes.manifiesto_carga

-- DROP TRIGGER anular_cxp_transferencia ON etes.manifiesto_carga;

CREATE TRIGGER anular_cxp_transferencia
  AFTER UPDATE
  ON etes.manifiesto_carga
  FOR EACH ROW
  EXECUTE PROCEDURE etes.anular_cxp_transferencia();

-- Trigger: crear_cxp_transferencia on etes.manifiesto_carga

-- DROP TRIGGER crear_cxp_transferencia ON etes.manifiesto_carga;

CREATE TRIGGER crear_cxp_transferencia
  AFTER UPDATE
  ON etes.manifiesto_carga
  FOR EACH ROW
  EXECUTE PROCEDURE etes.crear_cxp_transferencia();


