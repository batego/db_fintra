-- Table: recaudo.operacion_recaudo_bo

-- DROP TABLE recaudo.operacion_recaudo_bo;

CREATE TABLE recaudo.operacion_recaudo_bo
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT 'FINV'::character varying,
  entidad_recaudo character varying NOT NULL DEFAULT ''::character varying,
  usuario character varying(100) NOT NULL DEFAULT ''::character varying,
  clave character varying NOT NULL DEFAULT ''::character varying,
  cod_banco character varying(100) NOT NULL DEFAULT ''::character varying,
  tipo_registro character varying(100) NOT NULL DEFAULT ''::character varying,
  canal character varying(100) NOT NULL DEFAULT ''::character varying,
  oficina character varying(100) NOT NULL DEFAULT ''::character varying,
  cod_producto character varying(100) NOT NULL DEFAULT ''::character varying,
  nro_cuenta character varying NOT NULL DEFAULT ''::character varying,
  operador character varying(100) NOT NULL DEFAULT ''::character varying,
  fecha_transaccion character varying NOT NULL DEFAULT ''::character varying,
  hora_transaccion character varying NOT NULL DEFAULT ''::character varying,
  fecha_vcmto character varying NOT NULL DEFAULT ''::character varying,
  jornada character varying(1) NOT NULL DEFAULT ''::character varying,
  nro_terminal character varying(100) NOT NULL DEFAULT ''::character varying,
  tipo_consulta character varying(100) NOT NULL DEFAULT ''::character varying,
  referencia_1 character varying(100) NOT NULL DEFAULT ''::character varying,
  referencia2 character varying(100) NOT NULL DEFAULT ''::character varying,
  codigo_iac character varying(100) NOT NULL DEFAULT ''::character varying,
  efectivo character varying NOT NULL DEFAULT ''::character varying,
  ch_propios character varying(100) NOT NULL DEFAULT ''::character varying,
  canje character varying NOT NULL DEFAULT ''::character varying,
  ingreso_vario character varying NOT NULL DEFAULT ''::character varying,
  total_transaccion character varying NOT NULL DEFAULT ''::character varying,
  nro_autorizacion character varying(20) NOT NULL DEFAULT ''::character varying,
  datafono character varying(100) NOT NULL DEFAULT ''::character varying,
  nro_autorizacion_datafono character varying(100) NOT NULL DEFAULT ''::character varying,
  cod_motivo character varying(100) NOT NULL DEFAULT ''::character varying,
  nro_transac_cli character varying(100) NOT NULL DEFAULT ''::character varying,
  tipo_operacion character varying(100) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(100) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(100) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE recaudo.operacion_recaudo_bo
  OWNER TO postgres;

