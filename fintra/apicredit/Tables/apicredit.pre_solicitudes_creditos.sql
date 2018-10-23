-- Table: apicredit.pre_solicitudes_creditos

-- DROP TABLE apicredit.pre_solicitudes_creditos;

CREATE TABLE apicredit.pre_solicitudes_creditos
(
  id serial NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  numero_solicitud integer NOT NULL DEFAULT 0,
  producto character varying(6) NOT NULL DEFAULT ''::character varying,
  entidad character varying(20) NOT NULL DEFAULT ''::character varying,
  afiliado character varying(15) NOT NULL DEFAULT ''::character varying,
  valor_cuota numeric(11,2) NOT NULL DEFAULT 0,
  valor_aval numeric(11,2) NOT NULL DEFAULT 0,
  fecha_credito timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  monto_credito numeric(11,2) NOT NULL DEFAULT 0,
  numero_cuotas integer NOT NULL DEFAULT 0,
  fecha_pago timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  tipo_identificacion character varying(10) NOT NULL DEFAULT ''::character varying,
  identificacion character varying(15) NOT NULL DEFAULT ''::character varying,
  fecha_expedicion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  primer_nombre character varying(20) NOT NULL DEFAULT ''::character varying,
  primer_apellido character varying(20) NOT NULL DEFAULT ''::character varying,
  fecha_nacimiento timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  email character varying(50) NOT NULL DEFAULT ''::character varying,
  ingresos_usuario numeric(11,2) NOT NULL DEFAULT 0,
  id_convenio integer NOT NULL DEFAULT 0,
  estado_sol character varying(1) NOT NULL DEFAULT ''::character varying,
  codigorespuesta character varying(50) NOT NULL DEFAULT ''::character varying,
  score integer NOT NULL DEFAULT 0,
  clasificacion character varying(50) NOT NULL DEFAULT ''::character varying,
  comentario character varying(150) NOT NULL DEFAULT ''::character varying,
  empresa character varying(50) NOT NULL DEFAULT ''::character varying,
  etapa integer NOT NULL DEFAULT 0,
  acepta_terminos character varying(1) NOT NULL DEFAULT 'S'::character varying,
  extracto_electronico character varying(1) NOT NULL DEFAULT ''::character varying,
  recoge_firmas character varying(1) NOT NULL DEFAULT ''::character varying,
  asesor character varying(50) NOT NULL DEFAULT ''::character varying,
  total_obligaciones_financieras numeric(11,2) NOT NULL DEFAULT 0,
  total_gastos_familiares numeric(11,2) NOT NULL DEFAULT 0,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(50) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(50) NOT NULL DEFAULT ''::character varying,
  telefono character varying(12) NOT NULL DEFAULT ''::character varying,
  financia_aval boolean NOT NULL DEFAULT false,
  tipo_cliente character varying(50) NOT NULL DEFAULT ''::character varying,
  ciudad character varying(80) NOT NULL DEFAULT ''::character varying,
  lat character varying(80) NOT NULL DEFAULT ''::character varying,
  lng character varying(80) NOT NULL DEFAULT ''::character varying,
  rechazo_operaciones character varying(1) NOT NULL DEFAULT ''::character varying,
  departamento character varying(80) NOT NULL DEFAULT ''::character varying,
  qb numeric DEFAULT 0.00,
  qm numeric DEFAULT 0.00,
  qa numeric DEFAULT 0.00,
  porc_endeudamiento numeric DEFAULT 0.00,
  validar_cp character varying(1) NOT NULL DEFAULT ''::character varying,
  compra_cartera character varying(1) NOT NULL DEFAULT 'N'::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE apicredit.pre_solicitudes_creditos
  OWNER TO postgres;

