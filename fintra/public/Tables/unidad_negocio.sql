-- Table: unidad_negocio

-- DROP TABLE unidad_negocio;

CREATE TABLE unidad_negocio
(
  id serial NOT NULL,
  ciudad character varying(30) NOT NULL DEFAULT ''::character varying,
  cod character varying(6) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(30) NOT NULL DEFAULT ''::character varying,
  cod_central_riesgo character varying(30) DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  ref_1 character varying(30) NOT NULL DEFAULT ''::character varying,
  ref_2 character varying(30) NOT NULL DEFAULT ''::character varying,
  ref_3 character varying(30) NOT NULL DEFAULT ''::character varying,
  ref_4 character varying(50) NOT NULL DEFAULT ''::character varying,
  puntaje_maximo character varying(30) DEFAULT ''::character varying,
  minimo integer NOT NULL DEFAULT 0,
  maximo integer NOT NULL DEFAULT 0,
  cutoff integer NOT NULL DEFAULT 0,
  puntaje_maximo_buro integer NOT NULL DEFAULT 0,
  minimo_buro integer NOT NULL DEFAULT 0,
  maximo_buro integer NOT NULL DEFAULT 0,
  cutoff_buro integer NOT NULL DEFAULT 0,
  cutoff_total integer NOT NULL DEFAULT 0
)
WITH (
  OIDS=FALSE
);
ALTER TABLE unidad_negocio
  OWNER TO postgres;
GRANT ALL ON TABLE unidad_negocio TO postgres;
GRANT SELECT ON TABLE unidad_negocio TO msoto;

