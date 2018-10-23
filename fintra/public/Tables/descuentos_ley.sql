-- Table: descuentos_ley

-- DROP TABLE descuentos_ley;

CREATE TABLE descuentos_ley
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  id_ocupacion_laboral integer,
  descripcion character varying(200),
  smlv_inicial numeric(9,2),
  smlv_final numeric(9,2),
  total_descuento numeric(11,2),
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(10),
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_ocupacion_laboral_id FOREIGN KEY (id_ocupacion_laboral)
      REFERENCES ocupacion_laboral (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE descuentos_ley
  OWNER TO postgres;
GRANT ALL ON TABLE descuentos_ley TO postgres;
GRANT SELECT ON TABLE descuentos_ley TO msoto;

