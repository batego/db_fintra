-- Table: opav.historico_ofertas

-- DROP TABLE opav.historico_ofertas;

CREATE TABLE opav.historico_ofertas
(
  id_solicitud character varying(15),
  id_cliente character varying(10),
  id_oferta character varying(15),
  num_os character varying(15),
  descripcion text,
  last_update timestamp without time zone,
  creation_date timestamp without time zone,
  creation_user character varying(10),
  user_update character varying(10),
  reg_status character varying(1),
  nic character varying(10),
  fecha_entrega_oferta timestamp without time zone,
  creacion_fecha_entrega_oferta timestamp without time zone,
  usuario_entrega_oferta character varying(10),
  tipo_solicitud character varying(50),
  tipodistribucion character(10),
  noesvaloragregado integer,
  nombre_solicitud character varying(100),
  user_oferta character varying(10),
  fecha_oferta timestamp without time zone,
  consecutivo_oferta character varying(50),
  otras_consideraciones text,
  consideraciones text,
  idh serial NOT NULL,
  hcreation_date timestamp without time zone,
  esoficial character varying(1) DEFAULT '0'::character varying,
  otras_anulaciones text DEFAULT ''::text,
  user_generate character varying(10) DEFAULT ''::character varying,
  aviso character varying(30),
  interventor character varying(10) DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.historico_ofertas
  OWNER TO postgres;
GRANT ALL ON TABLE opav.historico_ofertas TO postgres;
GRANT SELECT ON TABLE opav.historico_ofertas TO consultareal;
