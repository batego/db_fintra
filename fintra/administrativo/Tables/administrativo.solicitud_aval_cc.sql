-- Table: administrativo.solicitud_aval_cc

-- DROP TABLE administrativo.solicitud_aval_cc;

CREATE TABLE administrativo.solicitud_aval_cc
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(6) NOT NULL DEFAULT 'FINV'::character varying,
  numero_solicitud character varying(10) NOT NULL DEFAULT ''::character varying,
  fecha_consulta timestamp without time zone NOT NULL DEFAULT now(),
  valor_solicitado numeric(15,2) NOT NULL DEFAULT 0.0,
  estado_sol character varying(1) NOT NULL DEFAULT 'P'::character varying,
  tipo_persona character varying(6) DEFAULT 'N'::character varying,
  valor_aprobado numeric(15,2) NOT NULL DEFAULT 0.0,
  tipo_negocio character varying(6) NOT NULL DEFAULT '03'::character varying,
  afiliado character varying(15) NOT NULL DEFAULT ''::character varying,
  cod_neg character varying(15),
  id_convenio integer NOT NULL DEFAULT 42,
  producto character varying(2) NOT NULL DEFAULT '03'::character varying,
  valor_producto numeric NOT NULL DEFAULT 0.0,
  cod_sector character varying(6) NOT NULL DEFAULT 'S26'::character varying,
  cod_subsector character varying(6) NOT NULL DEFAULT '100'::character varying,
  plazo character varying(10) NOT NULL DEFAULT ''::character varying,
  plazo_pr_cuota character varying(10) NOT NULL DEFAULT ''::character varying,
  fecha_primera_cuota timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  ciclo character varying(10) NOT NULL DEFAULT ''::character varying,
  tasa numeric(15,2) NOT NULL DEFAULT 0.0,
  referencia character varying(30) NOT NULL DEFAULT ''::character varying,
  procesado character varying(1) NOT NULL DEFAULT 'N'::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(15) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.solicitud_aval_cc
  OWNER TO postgres;

