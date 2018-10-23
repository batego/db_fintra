-- Table: etes.configcomerial_productos

-- DROP TABLE etes.configcomerial_productos;

CREATE TABLE etes.configcomerial_productos
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  periodo character varying(6) NOT NULL DEFAULT ''::character varying,
  id_eds integer NOT NULL,
  id_producto_es integer NOT NULL,
  descripcion_comercial character varying(100) NOT NULL DEFAULT ''::character varying,
  comision_afintra_xproducto character varying(1) NOT NULL DEFAULT 'N'::character varying,
  porcentaje_ganancia_producto numeric(11,2) DEFAULT (0)::numeric,
  valor_ganancia_producto numeric(11,2) DEFAULT (0)::numeric,
  precio_producto numeric(11,2) DEFAULT (0)::numeric,
  editar_precio character varying(1) NOT NULL DEFAULT 'S'::character varying,
  precio_ensession character varying(1) NOT NULL DEFAULT 'N'::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  orden_app integer NOT NULL DEFAULT 0,
  CONSTRAINT fk_confescom_idproducto FOREIGN KEY (id_producto_es)
      REFERENCES etes.productos_es (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_configcomerialprod_ideds FOREIGN KEY (id_eds)
      REFERENCES etes.estacion_servicio (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE etes.configcomerial_productos
  OWNER TO postgres;

