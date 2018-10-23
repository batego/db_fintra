-- Table: log_ms

-- DROP TABLE log_ms;

CREATE TABLE log_ms
(
  id_orden numeric(10,0),
  id_estado_negocio numeric(2,0),
  user_update character varying(50),
  last_update timestamp without time zone,
  exid_estado_negocio numeric(2,0),
  id serial NOT NULL,
  id_cliente numeric(10,0) NOT NULL,
  costo_oferta_applus numeric(18,2),
  costo_oferta_eca numeric(18,2),
  importe_oferta numeric(18,2),
  cuotas numeric(2,0),
  valor_cuotas_r numeric(18,2),
  detalle_inconsistencia text DEFAULT ''::text,
  fecha_envio_ws timestamp without time zone,
  last_update_finv timestamp without time zone DEFAULT '2008-01-01 00:00:00'::timestamp without time zone,
  marca_ws character varying(1) DEFAULT ''::character varying,
  fecha_oferta timestamp without time zone,
  fecha_registro timestamp without time zone,
  num_os character varying(15) DEFAULT ''::character varying,
  estudio_economico character varying(40) DEFAULT 'Consorcio ECA-Applus-Fintravalores'::character varying,
  simbolo_variable text DEFAULT ''::character varying,
  tipo_dtf character varying(8) NOT NULL DEFAULT ''::character varying,
  esquema_comision character varying(15) NOT NULL DEFAULT 'MODELO_NUEVO'::character varying,
  consecutivo character varying(30) DEFAULT ''::character varying,
  simbolo_variable_cr text DEFAULT ''::text,
  comentario character varying(50) DEFAULT ''::character varying,
  f_recepcion timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  esquema_financiacion character varying(10) NOT NULL DEFAULT 'NUEVO'::character varying,
  fecha_solicitud timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE log_ms
  OWNER TO postgres;
GRANT ALL ON TABLE log_ms TO postgres;
GRANT SELECT ON TABLE log_ms TO msoto;

