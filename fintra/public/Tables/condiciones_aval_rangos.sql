-- Table: condiciones_aval_rangos

-- DROP TABLE condiciones_aval_rangos;

CREATE TABLE condiciones_aval_rangos
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id_aval serial NOT NULL,
  dias_ini integer NOT NULL,
  dias_fin integer NOT NULL,
  porcentaje_aval numeric NOT NULL DEFAULT 0.00,
  creation_user character varying(10) NOT NULL,
  user_update character varying(10) NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  CONSTRAINT "condicionesavalrangosFK" FOREIGN KEY (id_aval)
      REFERENCES condiciones_aval (id_aval) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE condiciones_aval_rangos
  OWNER TO postgres;
GRANT ALL ON TABLE condiciones_aval_rangos TO postgres;
GRANT SELECT ON TABLE condiciones_aval_rangos TO msoto;
COMMENT ON TABLE condiciones_aval_rangos
  IS 'Porcentajes definidos para las condiciones de aval del afiliado';

