-- Table: etes.novedades

-- DROP TABLE etes.novedades;

CREATE TABLE etes.novedades
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  id_tipo_novedad integer NOT NULL,
  cod_novedad character varying(2) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(60) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_novedad_idtiponovedad FOREIGN KEY (id_tipo_novedad)
      REFERENCES etes.tipo_novedad (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE etes.novedades
  OWNER TO postgres;

