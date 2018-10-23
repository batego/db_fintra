-- Table: requisicion

-- DROP TABLE requisicion;

CREATE TABLE requisicion
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  id_tipo_requisicion integer NOT NULL,
  id_proceso_interno integer NOT NULL,
  radicado character varying(10) NOT NULL DEFAULT ''::character varying,
  fch_radicacion timestamp without time zone NOT NULL DEFAULT (now())::timestamp without time zone,
  usuario_generador character varying(15) NOT NULL DEFAULT ''::character varying,
  asunto character varying(200) NOT NULL DEFAULT ''::character varying,
  descripcion text NOT NULL DEFAULT ''::text,
  tipo_tarea integer NOT NULL DEFAULT 0,
  id_estado_requisicion integer NOT NULL DEFAULT 1,
  id_prioridad integer NOT NULL,
  orden_priorizacion integer NOT NULL DEFAULT 0,
  solucionador_responsable character varying(15) NOT NULL DEFAULT ''::character varying,
  moderado_por character varying(15) NOT NULL DEFAULT ''::character varying,
  autorizado integer NOT NULL DEFAULT 0,
  autorizado_por character varying(15) NOT NULL DEFAULT ''::character varying,
  fecha_inicio_estimado timestamp without time zone,
  fecha_fin_estimado timestamp without time zone,
  horas_trabajo numeric(11,2) NOT NULL DEFAULT (0)::numeric,
  fecha_inicio_actividades timestamp without time zone,
  fch_cierre timestamp without time zone,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  notificacion character varying(1) DEFAULT 'N'::character varying,
  CONSTRAINT "FK_req_empresa" FOREIGN KEY (dstrct)
      REFERENCES cia (dstrct) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_req_estado" FOREIGN KEY (id_estado_requisicion)
      REFERENCES estado_requisicion (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_req_prioridad_requisicion" FOREIGN KEY (id_prioridad)
      REFERENCES prioridad_requisicion (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_req_proceso_interno" FOREIGN KEY (id_proceso_interno)
      REFERENCES proceso_interno (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_req_tipo_requisicion" FOREIGN KEY (id_tipo_requisicion)
      REFERENCES tipo_requisicion (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE requisicion
  OWNER TO postgres;
GRANT ALL ON TABLE requisicion TO postgres;
GRANT SELECT ON TABLE requisicion TO msoto;

