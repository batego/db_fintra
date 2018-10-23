-- Table: opav.ofertas

-- DROP TABLE opav.ofertas;

CREATE TABLE opav.ofertas
(
  id_solicitud character varying(15) NOT NULL DEFAULT ''::character varying,
  id_cliente character varying(10) DEFAULT ''::character varying,
  id_oferta character varying(15) DEFAULT ''::character varying,
  num_os character varying(15) DEFAULT ''::character varying,
  descripcion text DEFAULT ''::text,
  last_update timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(10) DEFAULT ''::character varying,
  user_update character varying(10) DEFAULT ''::character varying,
  reg_status character varying(1) DEFAULT ''::character varying,
  nic character varying(10) DEFAULT ''::character varying,
  fecha_entrega_oferta timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  creacion_fecha_entrega_oferta timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  usuario_entrega_oferta character varying(10) DEFAULT ''::character varying,
  tipo_solicitud character varying(50) DEFAULT ''::character varying, -- Programado o ValorAgregado o Emergencia o Alquiler
  tipodistribucion character(10) DEFAULT '1'::bpchar,
  noesvaloragregado integer DEFAULT 1,
  nombre_solicitud character varying(100) DEFAULT ''::character varying,
  user_oferta character varying(10) DEFAULT ''::character varying,
  fecha_oferta timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  consecutivo_oferta character varying(50) DEFAULT ''::character varying,
  otras_consideraciones text DEFAULT ''::text,
  consideraciones text DEFAULT ''::text,
  esoficial character varying(1) DEFAULT '0'::character varying,
  otras_anulaciones text DEFAULT ''::text,
  user_generate character varying(10) DEFAULT ''::character varying,
  aviso character varying(30) DEFAULT ''::character varying,
  fecha_validacion_cartera timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  estudio_cartera character varying(10) DEFAULT 'Estudio'::character varying, -- posibles valores:...
  interventor character varying(15) DEFAULT ''::character varying,
  responsable character varying(12) NOT NULL DEFAULT ''::character varying, -- Contiene la identificacion del responsable de la opav el cual puede ser consultado en la tablagen 'RESPONSABL'
  comentario text NOT NULL DEFAULT ''::text,
  fecha_inicial_oferta timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  num_os_rel character varying(15) NOT NULL DEFAULT ''::character varying,
  nombre_proyecto character varying(160) DEFAULT ''::character varying,
  trazabilidad character varying(50) DEFAULT ''::character varying,
  estado integer,
  tipo_proyecto character varying(8) NOT NULL DEFAULT ''::character varying,
  nuevo_modulo integer NOT NULL DEFAULT 0, -- este iva solo existe cuando la cotizacion tiene AIU
  id_tipo_trabajo integer,
  id_tipo_negocio integer,
  centro_costos_ingreso character varying(100) NOT NULL DEFAULT ''::character varying,
  centro_costos_gastos character varying(100) NOT NULL DEFAULT ''::character varying,
  fecha_limite_entrega timestamp without time zone
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.ofertas
  OWNER TO postgres;
COMMENT ON COLUMN opav.ofertas.tipo_solicitud IS 'Programado o ValorAgregado o Emergencia o Alquiler';
COMMENT ON COLUMN opav.ofertas.estudio_cartera IS 'posibles valores:
Estudio : esta en estudio
000 : rechazada
010 : aprobada
';
COMMENT ON COLUMN opav.ofertas.responsable IS 'Contiene la identificacion del responsable de la opav el cual puede ser consultado en la tablagen ''RESPONSABL''';
COMMENT ON COLUMN opav.ofertas.nuevo_modulo IS 'este iva solo existe cuando la cotizacion tiene AIU';


-- Trigger: hofertas on opav.ofertas

-- DROP TRIGGER hofertas ON opav.ofertas;

CREATE TRIGGER hofertas
  AFTER INSERT OR UPDATE
  ON opav.ofertas
  FOR EACH ROW
  EXECUTE PROCEDURE insert_h_ofe();
