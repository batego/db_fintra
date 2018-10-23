-- Table: ex_ofertas

-- DROP TABLE ex_ofertas;

CREATE TABLE ex_ofertas
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
  aviso character varying(20) DEFAULT ''::character varying,
  fecha_validacion_cartera timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  estudio_cartera character varying(10) DEFAULT 'Estudio'::character varying, -- posibles valores:...
  interventor character varying(10) DEFAULT ''::character varying,
  responsable character varying(12) NOT NULL DEFAULT ''::character varying, -- Contiene la identificacion del responsable de la opav el cual puede ser consultado en la tablagen 'RESPONSABL'
  comentario text NOT NULL DEFAULT ''::text,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE ex_ofertas
  OWNER TO postgres;
GRANT ALL ON TABLE ex_ofertas TO postgres;
GRANT SELECT ON TABLE ex_ofertas TO msoto;
COMMENT ON COLUMN ex_ofertas.tipo_solicitud IS 'Programado o ValorAgregado o Emergencia o Alquiler';
COMMENT ON COLUMN ex_ofertas.estudio_cartera IS 'posibles valores:
Estudio : esta en estudio
000 : rechazada
010 : aprobada
';
COMMENT ON COLUMN ex_ofertas.responsable IS 'Contiene la identificacion del responsable de la opav el cual puede ser consultado en la tablagen ''RESPONSABL''';


