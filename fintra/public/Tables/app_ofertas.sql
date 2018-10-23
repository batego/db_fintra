-- Table: app_ofertas

-- DROP TABLE app_ofertas;

CREATE TABLE app_ofertas
(
  id_orden numeric(10,0) NOT NULL,
  id_cliente numeric(10,0) NOT NULL,
  costo_oferta_applus numeric(18,2),
  costo_oferta_eca numeric(18,2),
  importe_oferta numeric(18,2),
  id_estado_negocio numeric(2,0) NOT NULL,
  cuotas_reales numeric(3,0),
  valor_cuota numeric(18,2),
  detalle_inconsistencia text DEFAULT ''::text,
  fecha_envio_ws timestamp without time zone,
  last_update_finv timestamp without time zone DEFAULT '2008-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(50) DEFAULT '-'::character varying,
  marca_ws character varying(1) DEFAULT ''::character varying,
  fecha_oferta timestamp without time zone,
  fecha_registro timestamp without time zone,
  num_os character varying(15) DEFAULT ''::character varying,
  estudio_economico character varying(40) DEFAULT ''::character varying,
  simbolo_variable text DEFAULT ''::character varying,
  tipo_dtf character varying(8) NOT NULL DEFAULT ''::character varying,
  porcentaje_formula numeric(4,2) NOT NULL DEFAULT 2,
  factura_eca character varying(20) NOT NULL DEFAULT ''::character varying,
  fecha_factura_eca timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  esquema_comision character varying(25) NOT NULL DEFAULT 'MODELO_NUEVO'::character varying,
  observacion text NOT NULL DEFAULT ''::text,
  prefactura_eca character varying(1) NOT NULL DEFAULT 'N'::character varying,
  factura_app character varying(20) NOT NULL DEFAULT ''::character varying,
  fecha_factura_app timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  factura_pro character varying(20) NOT NULL DEFAULT ''::character varying,
  fecha_factura_pro timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  factura_comision_eca character varying NOT NULL DEFAULT ''::character varying,
  fecha_factura_comision_eca timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  esquema_financiacion character varying(10) NOT NULL DEFAULT 'NUEVO'::character varying,
  f_recepcion timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  exprefactura_eca character varying(1) NOT NULL DEFAULT 'N'::character varying,
  cxc_ap character varying(25) DEFAULT ''::character varying,
  cxc_pr character varying(25) DEFAULT ''::character varying,
  exnum_os character varying(15) DEFAULT ''::character varying,
  comentario character varying(100) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE app_ofertas
  OWNER TO postgres;
GRANT ALL ON TABLE app_ofertas TO postgres;
GRANT SELECT ON TABLE app_ofertas TO msoto;

