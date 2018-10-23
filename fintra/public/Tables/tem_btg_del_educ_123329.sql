-- Table: tem_btg_del_educ_123329

-- DROP TABLE tem_btg_del_educ_123329;

CREATE TABLE tem_btg_del_educ_123329
(
  id integer,
  dstrct character varying(4),
  reg_status character varying(1),
  numero_solicitud integer,
  producto character varying(6),
  entidad character varying(20),
  afiliado character varying(15),
  valor_cuota numeric(11,2),
  valor_aval numeric(11,2),
  fecha_credito timestamp without time zone,
  monto_credito numeric(11,2),
  numero_cuotas integer,
  fecha_pago timestamp without time zone,
  tipo_identificacion character varying(10),
  identificacion character varying(15),
  fecha_expedicion timestamp without time zone,
  primer_nombre character varying(20),
  primer_apellido character varying(20),
  fecha_nacimiento timestamp without time zone,
  email character varying(50),
  ingresos_usuario numeric(11,2),
  id_convenio integer,
  estado_sol character varying(1),
  codigorespuesta character varying(50),
  score integer,
  clasificacion character varying(50),
  comentario character varying(150),
  empresa character varying(50),
  etapa integer,
  acepta_terminos character varying(1),
  extracto_electronico character varying(1),
  recoge_firmas character varying(1),
  asesor character varying(50),
  total_obligaciones_financieras numeric(11,2),
  total_gastos_familiares numeric(11,2),
  creation_date timestamp without time zone,
  creation_user character varying(50),
  last_update timestamp without time zone,
  user_update character varying(50),
  telefono character varying(12),
  financia_aval boolean,
  tipo_cliente character varying(50),
  ciudad character varying(80),
  lat character varying(80),
  lng character varying(80),
  rechazo_operaciones character varying(1),
  departamento character varying(80),
  qb numeric,
  qm numeric,
  qa numeric,
  porc_endeudamiento numeric
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tem_btg_del_educ_123329
  OWNER TO postgres;

