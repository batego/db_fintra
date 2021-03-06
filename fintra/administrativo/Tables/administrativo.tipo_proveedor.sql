-- Table: administrativo.tipo_proveedor

-- DROP TABLE administrativo.tipo_proveedor;

CREATE TABLE administrativo.tipo_proveedor
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  descripcion character varying(200),
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(10) DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  codigo character varying(5)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.tipo_proveedor
  OWNER TO postgres;

