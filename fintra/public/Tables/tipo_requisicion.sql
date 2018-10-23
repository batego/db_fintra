-- Table: tipo_requisicion

-- DROP TABLE tipo_requisicion;

CREATE TABLE tipo_requisicion
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  descripcion character varying(100) NOT NULL DEFAULT ''::character varying,
  document_type character varying(60) NOT NULL DEFAULT ''::character varying,
  meta_eficacia integer DEFAULT 0,
  meta_eficiencia integer DEFAULT 0,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT 'HCUELLO'::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tipo_requisicion
  OWNER TO postgres;
GRANT ALL ON TABLE tipo_requisicion TO postgres;
GRANT SELECT ON TABLE tipo_requisicion TO msoto;

