-- Table: tareas_requisicion

-- DROP TABLE tareas_requisicion;

CREATE TABLE tareas_requisicion
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  id_requisicion integer NOT NULL,
  id_usuario_atiende integer NOT NULL,
  id_tipo_tarea integer NOT NULL,
  descripcion text NOT NULL DEFAULT ''::text,
  fecha_inicio_estimada timestamp without time zone,
  fecha_fin_estimada timestamp without time zone,
  horas_estimadas character varying(11) NOT NULL DEFAULT '0'::character varying,
  fecha_culminacion timestamp without time zone,
  horas_reproceso numeric(11,2) NOT NULL DEFAULT (0)::numeric,
  id_estado_tarea integer NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT 'HCUELLO'::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT "FK_tarea_estado" FOREIGN KEY (id_estado_tarea)
      REFERENCES estado_tareas_requisicion (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_tareas_requisicion" FOREIGN KEY (id_requisicion)
      REFERENCES requisicion (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_tipo_tarea" FOREIGN KEY (id_tipo_tarea)
      REFERENCES tipo_tarea (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_usuarios_atiende" FOREIGN KEY (id_usuario_atiende)
      REFERENCES usuarios (codigo_usuario) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tareas_requisicion
  OWNER TO postgres;
GRANT ALL ON TABLE tareas_requisicion TO postgres;
GRANT SELECT ON TABLE tareas_requisicion TO msoto;

