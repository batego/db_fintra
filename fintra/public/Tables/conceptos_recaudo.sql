-- Table: conceptos_recaudo

-- DROP TABLE conceptos_recaudo;

CREATE TABLE conceptos_recaudo
(
  id serial NOT NULL,
  id_unidad_negocio integer NOT NULL,
  categoria character varying(6) NOT NULL DEFAULT ''::character varying,
  prefijo character varying(25) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(30) NOT NULL DEFAULT ''::character varying,
  dias_rango_ini real NOT NULL DEFAULT 0,
  dias_rango_fin real NOT NULL DEFAULT 0,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_unidad_negocio_id FOREIGN KEY (id_unidad_negocio)
      REFERENCES unidad_negocio (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE conceptos_recaudo
  OWNER TO postgres;
GRANT ALL ON TABLE conceptos_recaudo TO postgres;
GRANT SELECT ON TABLE conceptos_recaudo TO msoto;

