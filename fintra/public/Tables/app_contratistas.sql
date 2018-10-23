-- Table: app_contratistas

-- DROP TABLE app_contratistas;

CREATE TABLE app_contratistas
(
  id_contratista character varying(5) NOT NULL,
  descripcion character varying(60) NOT NULL,
  last_update_finv timestamp without time zone,
  fecha_envio_ws timestamp without time zone,
  por_actualizar numeric(1,0) NOT NULL DEFAULT 0,
  secuencia_prefactura numeric(6,0) DEFAULT 0,
  nit character varying(15),
  exid_contratista character varying(5) DEFAULT ''::character varying,
  email text DEFAULT ''::text,
  exemail text DEFAULT ''::text,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE app_contratistas
  OWNER TO postgres;
GRANT ALL ON TABLE app_contratistas TO postgres;
GRANT SELECT ON TABLE app_contratistas TO msoto;

