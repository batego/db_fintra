-- Table: etes.ventas_eds_tsp

-- DROP TABLE etes.ventas_eds_tsp;

CREATE TABLE etes.ventas_eds_tsp
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  id_transportadora integer NOT NULL,
  id_manifiesto_carga integer NOT NULL,
  id_eds integer NOT NULL,
  num_venta character varying(100) NOT NULL DEFAULT ''::character varying,
  fecha_venta timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  periodo character varying(6) NOT NULL DEFAULT ''::character varying,
  kilometraje numeric(11,0) DEFAULT (0)::numeric,
  id_producto integer NOT NULL,
  precio_producto_xunidadmedida numeric(11,2) DEFAULT (0)::numeric,
  cantidad_suministrada numeric(11,2) DEFAULT (0)::numeric,
  total_venta numeric(11,0) DEFAULT (0)::numeric,
  id_configcomercial_producto integer NOT NULL,
  valor_comision_fintra numeric(11,0) DEFAULT (0)::numeric,
  documento_cxp character varying(50) DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_ventaseds_idconfigcomprod_tsp FOREIGN KEY (id_configcomercial_producto)
      REFERENCES etes.configcomerial_productos (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_ventaseds_ideds_tsp FOREIGN KEY (id_eds)
      REFERENCES etes.estacion_servicio (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_ventaseds_idproductos_tsp FOREIGN KEY (id_producto)
      REFERENCES etes.productos_es (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE etes.ventas_eds_tsp
  OWNER TO postgres;

