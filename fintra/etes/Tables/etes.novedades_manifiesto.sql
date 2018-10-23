-- Table: etes.novedades_manifiesto

-- DROP TABLE etes.novedades_manifiesto;

CREATE TABLE etes.novedades_manifiesto
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  id_novedad integer NOT NULL,
  id_manifiesto_carga integer NOT NULL,
  cod_novedad character varying(2) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(60) NOT NULL DEFAULT ''::character varying,
  creation_user character varying(20) NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  CONSTRAINT fk_novmanif_idnovedad FOREIGN KEY (id_novedad)
      REFERENCES etes.novedades (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_novmanif_manifiesto_carga FOREIGN KEY (id_manifiesto_carga)
      REFERENCES etes.manifiesto_carga (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE etes.novedades_manifiesto
  OWNER TO postgres;

