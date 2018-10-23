-- Table: tipo_distribucion_eca

-- DROP TABLE tipo_distribucion_eca;

CREATE TABLE tipo_distribucion_eca
(
  tipo character varying(10) NOT NULL DEFAULT ''::character varying,
  porc_opav numeric(9,6) DEFAULT 0,
  porc_fintra numeric(9,6) DEFAULT 0,
  porc_interventoria numeric(9,6) DEFAULT 0,
  porc_provintegral numeric(9,6) DEFAULT 0,
  porc_eca numeric(9,6) DEFAULT 0, -- este incremento no se hace sobre costo contratista sino sobre el valor ya incrementado
  porc_iva numeric(9,6) DEFAULT 0,
  valor_agregado character varying(1) NOT NULL DEFAULT 'N'::character varying,
  creation_date timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  creation_user character varying(10) DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tipo_distribucion_eca
  OWNER TO postgres;
GRANT ALL ON TABLE tipo_distribucion_eca TO postgres;
GRANT SELECT ON TABLE tipo_distribucion_eca TO msoto;
COMMENT ON COLUMN tipo_distribucion_eca.porc_eca IS 'este incremento no se hace sobre costo contratista sino sobre el valor ya incrementado';


