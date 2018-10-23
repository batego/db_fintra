-- Table: administrativo.novedades

-- DROP TABLE administrativo.novedades;

CREATE TABLE administrativo.novedades
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id_tipo integer NOT NULL,
  fecha_solicitud timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  cc_empleado character varying(15) NOT NULL DEFAULT ''::character varying,
  fecha_ini timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  duracion_dias integer DEFAULT 0,
  fecha_fin timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  hora_ini time without time zone,
  duracion_horas integer DEFAULT 0,
  hora_fin time without time zone,
  cod_enfermedad character varying(5) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(500) NOT NULL DEFAULT ''::character varying,
  aprobado character varying(1) NOT NULL DEFAULT 'P'::character varying,
  comentario character varying(50) NOT NULL DEFAULT ''::character varying,
  fecha_autoriza timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_autoriza character varying(30) NOT NULL DEFAULT ''::character varying,
  remunerada character varying(1) NOT NULL DEFAULT 'P'::character varying, -- Indica si ya se le dio visto bueno, por defecto esta en P de pendiente, y cambia a S.
  fecha_visto_bueno timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_visto_bueno character varying(10) NOT NULL DEFAULT ''::character varying,
  observaciones character varying(300) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  dias_compensados integer NOT NULL DEFAULT 0,
  dias_disfrute integer,
  dias_a_pagar integer,
  razon integer,
  recobro character varying(1) NOT NULL DEFAULT ''::character varying,
  tramitada character varying(1),
  id_proceso character varying,
  fecha_cambio_proceso timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  numsolicitud character varying(10) NOT NULL DEFAULT ''::character varying,
  origen character varying(20),
  valor_eps numeric,
  valor_arl numeric,
  pagar character varying(1) DEFAULT 'P'::character varying, -- Indica si el permiso si se debe pagar normal (S) , o si se debe descontar(N).
  CONSTRAINT novedades_id_tipo_fkey FOREIGN KEY (id_tipo)
      REFERENCES administrativo.tipo_novedad (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.novedades
  OWNER TO postgres;
COMMENT ON COLUMN administrativo.novedades.remunerada IS 'Indica si ya se le dio visto bueno, por defecto esta en P de pendiente, y cambia a S.';
COMMENT ON COLUMN administrativo.novedades.pagar IS 'Indica si el permiso si se debe pagar normal (S) , o si se debe descontar(N).';


