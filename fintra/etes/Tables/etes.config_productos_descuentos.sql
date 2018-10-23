-- Table: etes.config_productos_descuentos

-- DROP TABLE etes.config_productos_descuentos;

CREATE TABLE etes.config_productos_descuentos
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  id_transportadora integer NOT NULL,
  id_proserv integer NOT NULL,
  id_tipo_descuentos integer NOT NULL,
  descripcion_descuento character varying(200) NOT NULL DEFAULT ''::character varying,
  descripcion_corta character varying(20) NOT NULL DEFAULT ''::character varying,
  porcentaje_descuento numeric(11,2) DEFAULT (0)::numeric,
  valor_descuento numeric(11,0) DEFAULT (0)::numeric,
  CONSTRAINT fk_confprodes_idproserv FOREIGN KEY (id_proserv)
      REFERENCES etes.productos_servicios_transp (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_confprodes_idtipodesc FOREIGN KEY (id_tipo_descuentos)
      REFERENCES etes.tipo_descuentos (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_confprodes_idtransp FOREIGN KEY (id_transportadora)
      REFERENCES etes.transportadoras (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE etes.config_productos_descuentos
  OWNER TO postgres;

-- Trigger: crear_reporte_produccion on etes.config_productos_descuentos

-- DROP TRIGGER crear_reporte_produccion ON etes.config_productos_descuentos;

CREATE TRIGGER crear_reporte_produccion
  AFTER INSERT
  ON etes.config_productos_descuentos
  FOR EACH ROW
  EXECUTE PROCEDURE etes.crear_reporte_produccion();


