-- Table: configuracion_descuentos_obligaciones

-- DROP TABLE configuracion_descuentos_obligaciones;

CREATE TABLE configuracion_descuentos_obligaciones
(
  id serial NOT NULL,
  concepto character varying(15) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(30) NOT NULL DEFAULT ''::character varying,
  descuento integer NOT NULL DEFAULT 0,
  porcentaje_cta_inicial integer NOT NULL DEFAULT 0,
  aplica_incial character varying(1) NOT NULL DEFAULT ''::character varying,
  periodo integer NOT NULL DEFAULT 0,
  tipo_negocio character varying(20) NOT NULL DEFAULT ''::character varying,
  id_unidad_negocio integer NOT NULL DEFAULT 0,
  creation_date timestamp without time zone,
  creation_user character varying(20) NOT NULL,
  last_update timestamp without time zone,
  user_update character varying(20),
  dstrct character varying(6) NOT NULL DEFAULT ''::character varying,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE configuracion_descuentos_obligaciones
  OWNER TO postgres;
GRANT ALL ON TABLE configuracion_descuentos_obligaciones TO postgres;
GRANT SELECT ON TABLE configuracion_descuentos_obligaciones TO msoto;

