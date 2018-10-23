-- Table: etes.manifiesto_descuentos

-- DROP TABLE etes.manifiesto_descuentos;

CREATE TABLE etes.manifiesto_descuentos
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  id_manifiesto_carga integer NOT NULL,
  planilla character varying(20) NOT NULL DEFAULT ''::character varying,
  reanticipo character varying(1) NOT NULL DEFAULT 'N'::character varying,
  id_productos_descuentos integer NOT NULL,
  fecha_aplicacion_descuento timestamp without time zone NOT NULL DEFAULT (now())::timestamp without time zone,
  porcentaje_descuento numeric(11,2) DEFAULT (0)::numeric,
  valor_descuento numeric(11,2) DEFAULT (0)::numeric,
  CONSTRAINT fk_manifdescuento_idmanifiesto FOREIGN KEY (id_manifiesto_carga)
      REFERENCES etes.manifiesto_carga (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_manifdescuento_idprodesc FOREIGN KEY (id_productos_descuentos)
      REFERENCES etes.config_productos_descuentos (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE etes.manifiesto_descuentos
  OWNER TO postgres;

