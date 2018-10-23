-- Table: cr_obligaciones_areportar_criesgo

-- DROP TABLE cr_obligaciones_areportar_criesgo;

CREATE TABLE cr_obligaciones_areportar_criesgo
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  periodo_lote character varying(6),
  id_unidad_negocio integer,
  negocio_reportado character varying(15),
  identificacion character varying(20),
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(10),
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  fecha_reporte timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  reportado character varying(1) NOT NULL DEFAULT 'N'::character varying,
  valida_criesgo character varying(1) NOT NULL DEFAULT 'N'::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cr_obligaciones_areportar_criesgo
  OWNER TO postgres;
GRANT ALL ON TABLE cr_obligaciones_areportar_criesgo TO postgres;
GRANT SELECT ON TABLE cr_obligaciones_areportar_criesgo TO msoto;

