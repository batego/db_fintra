-- Table: administrativo.productos

-- DROP TABLE administrativo.productos;

CREATE TABLE administrativo.productos
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  descripcion character varying(200),
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(10) DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  id_linea_negocio integer NOT NULL,
  convenio character varying DEFAULT ''::character varying,
  CONSTRAINT productos_id_linea_negocio_fkey FOREIGN KEY (id_linea_negocio)
      REFERENCES unidad_negocio (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.productos
  OWNER TO postgres;

