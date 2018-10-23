-- Table: etes.ventas_eds

-- DROP TABLE etes.ventas_eds;

CREATE TABLE etes.ventas_eds
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  id_manifiesto_carga integer NOT NULL,
  id_eds integer NOT NULL,
  num_venta character varying(100) NOT NULL DEFAULT ''::character varying,
  fecha_venta timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  periodo character varying(6) NOT NULL DEFAULT ''::character varying,
  kilometraje numeric(11,0) DEFAULT (0)::numeric,
  id_producto integer NOT NULL,
  precio_producto_xunidadmedida numeric(11,2) DEFAULT (0)::numeric,
  cantidad_suministrada numeric(12,5) DEFAULT (0)::numeric,
  total_venta numeric(12,5) DEFAULT (0)::numeric,
  id_configcomercial_producto integer NOT NULL,
  valor_comision_fintra numeric(12,5) DEFAULT (0)::numeric,
  documento_cxp character varying(50) DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_ventaseds_idconfcom FOREIGN KEY (id_manifiesto_carga)
      REFERENCES etes.manifiesto_carga (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_ventaseds_idconfigcomprod FOREIGN KEY (id_configcomercial_producto)
      REFERENCES etes.configcomerial_productos (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_ventaseds_ideds FOREIGN KEY (id_eds)
      REFERENCES etes.estacion_servicio (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_ventaseds_idproductos FOREIGN KEY (id_producto)
      REFERENCES etes.productos_es (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE etes.ventas_eds
  OWNER TO postgres;

