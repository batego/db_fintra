-- Table: con.planillas_procesadas_ut

-- DROP TABLE con.planillas_procesadas_ut;

CREATE TABLE con.planillas_procesadas_ut
(
  planilla character varying(20) NOT NULL DEFAULT ''::character varying,
  factura_cxp character varying(50) NOT NULL DEFAULT ''::character varying,
  factura_cxc character varying(50) NOT NULL DEFAULT ''::character varying,
  egreso character varying(20) NOT NULL DEFAULT ''::character varying,
  tipo_operacion character varying(3) NOT NULL DEFAULT ''::character varying,
  creation_date_planilla timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  procesado_nacimiento character varying(1) NOT NULL DEFAULT 'S'::character varying,
  procesado_egreso character varying(1) NOT NULL DEFAULT 'N'::character varying,
  procesado_cxc character varying(1) NOT NULL DEFAULT 'N'::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.planillas_procesadas_ut
  OWNER TO postgres;

