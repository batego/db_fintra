-- Table: sanciones_condonaciones

-- DROP TABLE sanciones_condonaciones;

CREATE TABLE sanciones_condonaciones
(
  id serial NOT NULL,
  id_unidad_negocio integer NOT NULL,
  id_tipo_acto integer NOT NULL,
  id_conceptos_recaudo integer NOT NULL,
  periodo character varying(6) NOT NULL DEFAULT ''::character varying,
  categoria character varying(6) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(80) NOT NULL DEFAULT ''::character varying,
  aplicado_a character varying(6) NOT NULL DEFAULT ''::character varying,
  dias_rango_ini numeric(11,0) NOT NULL DEFAULT 0,
  dias_rango_fin numeric(11,0) NOT NULL DEFAULT 0,
  porcentaje character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_tipo_acto_id FOREIGN KEY (id_tipo_acto)
      REFERENCES tipo_acto (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_unidad_negocio_id FOREIGN KEY (id_unidad_negocio)
      REFERENCES unidad_negocio (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE sanciones_condonaciones
  OWNER TO postgres;
GRANT ALL ON TABLE sanciones_condonaciones TO postgres;
GRANT SELECT ON TABLE sanciones_condonaciones TO msoto;

