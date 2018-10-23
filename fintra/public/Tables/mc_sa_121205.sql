-- Table: mc_sa_121205

-- DROP TABLE mc_sa_121205;

CREATE TABLE mc_sa_121205
(
  reg_status character varying(1),
  dstrct character varying(6),
  numero_solicitud integer,
  fecha_consulta timestamp without time zone,
  valor_solicitado numeric(15,2),
  agente character varying(60),
  afiliado character varying(15),
  codigo character varying(12),
  numero_aprobacion character varying(15),
  estado_sol character varying(1),
  tipo_persona character varying(6),
  valor_aprobado numeric(15,2),
  tipo_negocio character varying(6),
  num_tipo_negocio character varying(30),
  banco character varying(6),
  sucursal character varying(30),
  num_chequera character varying(30),
  cod_neg character varying(15),
  creation_date timestamp without time zone,
  creation_user character varying(50),
  last_update timestamp without time zone,
  user_update character varying(50),
  asesor character varying(50),
  id_convenio integer,
  producto character varying(2),
  servicio character varying(2),
  ciudad_matricula character varying(2),
  valor_producto numeric,
  cod_sector character varying(6),
  cod_subsector character varying(6),
  plazo character varying(10),
  plazo_pr_cuota character varying(10),
  ciudad_cheque character varying(4),
  mod_formulario text,
  renovacion character varying(10),
  fecha_primera_cuota timestamp without time zone,
  cod_negocio_renovado character varying(15),
  pre_aprobado_micro character varying(1),
  score_buro character varying(50),
  score_lisim character varying(50),
  score_total character varying(50),
  accion_sugerida character varying(200),
  capacidad_endeudamiento character varying(50),
  cuotas_pendientes character varying(50),
  altura_mora_actual_titular character varying(50),
  altura_mora_history_titular character varying(50),
  altura_mora_actual_codeudor character varying(50),
  altura_mora_history_codeudor character varying(50),
  fianza character varying(1),
  responsable_cuenta character varying(100),
  fecha_reasignacion timestamp without time zone
)
WITH (
  OIDS=FALSE
);
ALTER TABLE mc_sa_121205
  OWNER TO postgres;

