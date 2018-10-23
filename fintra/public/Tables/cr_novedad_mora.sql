-- Table: cr_novedad_mora

-- DROP TABLE cr_novedad_mora;

CREATE TABLE cr_novedad_mora
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  id_central_riesgo integer NOT NULL,
  id_unidad_negocio integer NOT NULL,
  novedad_mora character varying(60) NOT NULL DEFAULT ''::character varying,
  cod_novedad_mora character varying(2) NOT NULL DEFAULT ''::character varying,
  peso_novedad numeric(11,0) NOT NULL DEFAULT 0,
  dias_rango_ini numeric(11,0) NOT NULL DEFAULT 0,
  dias_rango_fin numeric(11,0) NOT NULL DEFAULT 0,
  monto_ini numeric(11,0) NOT NULL DEFAULT 0,
  monto_fin numeric(11,0) NOT NULL DEFAULT 0,
  marcacion_cartera character varying(30) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cr_novedad_mora
  OWNER TO postgres;
GRANT ALL ON TABLE cr_novedad_mora TO postgres;
GRANT SELECT ON TABLE cr_novedad_mora TO msoto;

