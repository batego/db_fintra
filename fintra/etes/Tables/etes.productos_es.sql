-- Table: etes.productos_es

-- DROP TABLE etes.productos_es;

CREATE TABLE etes.productos_es
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  cod_producto character varying(10) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(100) NOT NULL DEFAULT ''::character varying,
  id_unidad_medida integer NOT NULL,
  inmodificable character varying(1) NOT NULL DEFAULT 'N'::character varying,
  CONSTRAINT fk_productoses_umedida FOREIGN KEY (id_unidad_medida)
      REFERENCES etes.unidad_medida (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE etes.productos_es
  OWNER TO postgres;

