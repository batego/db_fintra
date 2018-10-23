-- Table: solicitud_aval

-- DROP TABLE solicitud_aval;

CREATE TABLE solicitud_aval
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(6) NOT NULL DEFAULT ''::character varying,
  numero_solicitud integer NOT NULL DEFAULT 0,
  fecha_consulta timestamp without time zone NOT NULL DEFAULT now(),
  valor_solicitado numeric(15,2) NOT NULL DEFAULT 0.0,
  agente character varying(60) NOT NULL DEFAULT ''::character varying,
  afiliado character varying(15) NOT NULL DEFAULT ''::character varying,
  codigo character varying(12) DEFAULT ''::character varying,
  numero_aprobacion character varying(15) DEFAULT ''::character varying,
  estado_sol character varying(1) NOT NULL DEFAULT 'B'::character varying,
  tipo_persona character varying(6) DEFAULT 'N'::character varying,
  valor_aprobado numeric(15,2) NOT NULL DEFAULT 0.0,
  tipo_negocio character varying(6) NOT NULL DEFAULT ''::character varying,
  num_tipo_negocio character varying(30) NOT NULL DEFAULT ''::character varying,
  banco character varying(6),
  sucursal character varying(30) NOT NULL DEFAULT ''::character varying,
  num_chequera character varying(30) NOT NULL DEFAULT ''::character varying,
  cod_neg character varying(15),
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(50) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone DEFAULT now(),
  user_update character varying(50) NOT NULL DEFAULT ''::character varying,
  asesor character varying(50) NOT NULL DEFAULT ''::character varying,
  id_convenio integer NOT NULL,
  producto character varying(2) NOT NULL DEFAULT ''::character varying,
  servicio character varying(2) NOT NULL DEFAULT ''::character varying,
  ciudad_matricula character varying(2) NOT NULL DEFAULT ''::character varying,
  valor_producto numeric NOT NULL DEFAULT 0.0,
  cod_sector character varying(6),
  cod_subsector character varying(6),
  plazo character varying(10) NOT NULL DEFAULT ''::character varying,
  plazo_pr_cuota character varying(10) NOT NULL DEFAULT ''::character varying,
  ciudad_cheque character varying(4) NOT NULL DEFAULT ''::character varying,
  mod_formulario text NOT NULL DEFAULT ''::text,
  renovacion character varying(10) DEFAULT ''::character varying,
  fecha_primera_cuota timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  cod_negocio_renovado character varying(15) DEFAULT ''::character varying,
  pre_aprobado_micro character varying(1) NOT NULL DEFAULT 'N'::character varying,
  score_buro character varying(50) NOT NULL DEFAULT '0'::character varying,
  score_lisim character varying(50) NOT NULL DEFAULT '0'::character varying,
  score_total character varying(50) NOT NULL DEFAULT '0'::character varying,
  accion_sugerida character varying(200) NOT NULL DEFAULT ''::character varying,
  capacidad_endeudamiento character varying(50) NOT NULL DEFAULT '0'::character varying,
  cuotas_pendientes character varying(50) NOT NULL DEFAULT '0/0'::character varying,
  altura_mora_actual_titular character varying(50) NOT NULL DEFAULT '0'::character varying,
  altura_mora_history_titular character varying(50) NOT NULL DEFAULT '0'::character varying,
  altura_mora_actual_codeudor character varying(50) NOT NULL DEFAULT '0'::character varying,
  altura_mora_history_codeudor character varying(50) NOT NULL DEFAULT '0'::character varying,
  fianza character varying(1) NOT NULL DEFAULT 'N'::character varying,
  responsable_cuenta character varying(100) NOT NULL DEFAULT ''::character varying,
  fecha_reasignacion timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  aprobado_score character varying NOT NULL DEFAULT 'N'::character varying,
  razon_quanto character varying(500),
  CONSTRAINT fk_bancos FOREIGN KEY (dstrct, banco)
      REFERENCES bancos (dstrct, codigo) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_negocios FOREIGN KEY (cod_neg)
      REFERENCES negocios (cod_neg) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_sector FOREIGN KEY (cod_sector)
      REFERENCES sector (cod_sector) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_subsector FOREIGN KEY (cod_sector, cod_subsector)
      REFERENCES subsector (cod_sector, cod_subsector) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE solicitud_aval
  OWNER TO postgres;
GRANT ALL ON TABLE solicitud_aval TO postgres;
GRANT SELECT ON TABLE solicitud_aval TO msoto;

-- Trigger: anular_persona_renovacion on solicitud_aval

-- DROP TRIGGER anular_persona_renovacion ON solicitud_aval;

CREATE TRIGGER anular_persona_renovacion
  BEFORE UPDATE
  ON solicitud_aval
  FOR EACH ROW
  EXECUTE PROCEDURE anular_negocio_renovacion();

-- Trigger: t_actualiza_plazo_credito on solicitud_aval

-- DROP TRIGGER t_actualiza_plazo_credito ON solicitud_aval;

CREATE TRIGGER t_actualiza_plazo_credito
  AFTER UPDATE
  ON solicitud_aval
  FOR EACH ROW
  EXECUTE PROCEDURE actualiza_plazo_credito();

-- Trigger: tu_crear_cliente on solicitud_aval

-- DROP TRIGGER tu_crear_cliente ON solicitud_aval;

CREATE TRIGGER tu_crear_cliente
  BEFORE UPDATE
  ON solicitud_aval
  FOR EACH ROW
  EXECUTE PROCEDURE tu_crear_cliente();


ALTER TABLE solicitud_aval ADD COLUMN id_sucursal INTEGER NOT NULL DEFAULT 0;