-- Table: administrativo.negocios_xliquidacion

-- DROP TABLE administrativo.negocios_xliquidacion;

CREATE TABLE administrativo.negocios_xliquidacion
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(6) NOT NULL DEFAULT 'FINV'::character varying,
  numero_solicitud character varying(10) NOT NULL DEFAULT ''::character varying,
  fecha_consulta timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  valor_solicitado numeric(15,2) NOT NULL DEFAULT 0.0,
  valor_aprobado numeric(15,2) NOT NULL DEFAULT 0.0,
  cod_neg character varying(15),
  id_convenio integer NOT NULL DEFAULT 43,
  plazo character varying(10) NOT NULL DEFAULT ''::character varying,
  plazo_pr_cuota character varying(10) NOT NULL DEFAULT ''::character varying,
  fecha_primera_cuota timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  ciclo character varying(10) NOT NULL DEFAULT ''::character varying,
  tasa numeric(15,2) NOT NULL DEFAULT 0.0,
  referencia character varying(30) NOT NULL DEFAULT ''::character varying,
  estado character varying(2) NOT NULL DEFAULT 'NP'::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(15) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.negocios_xliquidacion
  OWNER TO postgres;

