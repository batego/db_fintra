-- Table: estado_requisicion

-- DROP TABLE estado_requisicion;

CREATE TABLE estado_requisicion
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  descripcion character varying(50) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT 'HCUELLO'::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE estado_requisicion
  OWNER TO postgres;
GRANT ALL ON TABLE estado_requisicion TO postgres;
GRANT SELECT ON TABLE estado_requisicion TO msoto;

