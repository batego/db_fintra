-- Table: etes.tipo_novedad

-- DROP TABLE etes.tipo_novedad;

CREATE TABLE etes.tipo_novedad
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  id_proserv integer NOT NULL,
  descripcion character varying(60) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_tiponovedad_idproserv FOREIGN KEY (id_proserv)
      REFERENCES etes.productos_servicios_transp (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE etes.tipo_novedad
  OWNER TO postgres;

