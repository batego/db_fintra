-- Table: trazabilidad_asesores

-- DROP TABLE trazabilidad_asesores;

CREATE TABLE trazabilidad_asesores
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(6) NOT NULL DEFAULT 'FINV'::character varying,
  asesor_antiguo character varying(50) NOT NULL DEFAULT ''::character varying,
  asesor_nuevo character varying(50) NOT NULL DEFAULT ''::character varying,
  negocio character varying(15) NOT NULL DEFAULT ''::character varying,
  cliente character varying(20) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE trazabilidad_asesores
  OWNER TO postgres;

