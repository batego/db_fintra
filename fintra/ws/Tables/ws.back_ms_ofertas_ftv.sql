-- Table: ws.back_ms_ofertas_ftv

-- DROP TABLE ws.back_ms_ofertas_ftv;

CREATE TABLE ws.back_ms_ofertas_ftv
(
  id_orden numeric(10,0),
  id_cliente numeric(10,0),
  costo_oferta_applus numeric(18,2),
  costo_oferta_eca numeric(18,2),
  importe_oferta numeric(18,2),
  id_estado_negocio numeric(2,0),
  cuotas numeric(2,0),
  valor_cuotas_r numeric(18,2),
  detalle_inconsistencia text,
  fecha_envio_ws timestamp without time zone,
  last_update_finv timestamp without time zone,
  user_update character varying(50),
  marca_ws character varying(1),
  fecha_oferta timestamp without time zone,
  fecha_registro timestamp without time zone,
  num_os character varying(15),
  estudio_economico character varying(40),
  simbolo_variable text,
  tipo_dtf character varying(8),
  esquema_comision character varying(15),
  consecutivo character varying(30),
  simbolo_variable_cr text,
  comentario character varying(50),
  f_recepcion timestamp without time zone,
  esquema_financiacion character varying(10),
  fecha_solicitud timestamp without time zone,
  exnum_os character varying(15),
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE ws.back_ms_ofertas_ftv
  OWNER TO postgres;

