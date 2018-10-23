-- Table: opav.app_contratistas

-- DROP TABLE opav.app_contratistas;

CREATE TABLE opav.app_contratistas
(
  id_contratista character varying(5) NOT NULL,
  descripcion character varying(60) NOT NULL,
  last_update_finv timestamp without time zone,
  fecha_envio_ws timestamp without time zone,
  por_actualizar numeric(1,0) NOT NULL DEFAULT 0,
  secuencia_prefactura numeric(6,0) DEFAULT 0,
  nit character varying(15),
  exid_contratista character varying(5) DEFAULT ''::character varying,
  email text DEFAULT ''::text,
  exemail text DEFAULT ''::text,
  clave character varying(10) NOT NULL DEFAULT ''::character varying,
  codigo_reteica character varying(6) NOT NULL DEFAULT ''::character varying,
  gran_contribuyente character varying(2) NOT NULL DEFAULT 'NO'::character varying, -- SI=El proveedor es gran contribuyente, NO= No es gran contribuyente
  domicilio_comercial character varying(10) NOT NULL DEFAULT ''::character varying, -- Codigo de la ciudad del domicilio comercial
  actividad character varying(2) NOT NULL DEFAULT ''::character varying, -- Codigo correspondiente al tipo de actividad registrada para ese proveedor
  regimen character varying(12) NOT NULL DEFAULT ''::character varying, -- Regimen tributario : COMUN, SIMPLIFICADO, NATURAL
  autoretenedor character varying(2) NOT NULL DEFAULT 'NO'::character varying, -- Indica si se aplica retencion ...
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  contrato_mandato character(1) DEFAULT 'N'::bpchar,
  email_compras character varying(50) DEFAULT ''::character varying,
  responsable character varying(100) DEFAULT ''::character varying,
  direccion character varying(100) DEFAULT ''::character varying,
  telefono character varying(50) DEFAULT ''::character varying,
  celular character varying(50) DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.app_contratistas
  OWNER TO postgres;
GRANT ALL ON TABLE opav.app_contratistas TO postgres;
GRANT ALL ON TABLE opav.app_contratistas TO fintravaloressa;
GRANT SELECT ON TABLE opav.app_contratistas TO consulta2;
GRANT SELECT ON TABLE opav.app_contratistas TO consultareal;
COMMENT ON COLUMN opav.app_contratistas.gran_contribuyente IS 'SI=El proveedor es gran contribuyente, NO= No es gran contribuyente
';
COMMENT ON COLUMN opav.app_contratistas.domicilio_comercial IS 'Codigo de la ciudad del domicilio comercial
';
COMMENT ON COLUMN opav.app_contratistas.actividad IS 'Codigo correspondiente al tipo de actividad registrada para ese proveedor';
COMMENT ON COLUMN opav.app_contratistas.regimen IS 'Regimen tributario : COMUN, SIMPLIFICADO, NATURAL
';
COMMENT ON COLUMN opav.app_contratistas.autoretenedor IS ' Indica si se aplica retencion ...
';
