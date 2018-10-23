-- Table: opav.app_historico_costo_proveedor

-- DROP TABLE opav.app_historico_costo_proveedor;

CREATE TABLE opav.app_historico_costo_proveedor
(
  id serial NOT NULL,
  id_proveedor_materiales integer NOT NULL,
  fecha_ultima_compra timestamp with time zone DEFAULT '0099-01-01 00:00:00-04:56:20'::timestamp with time zone,
  costo_base numeric(11,2) DEFAULT 0,
  costo_dscto numeric(11,2) DEFAULT 0,
  costo_total numeric(11,2) DEFAULT 0,
  creation_user character varying(10),
  creation_date timestamp without time zone DEFAULT now(),
  user_update character varying(10),
  last_update timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.app_historico_costo_proveedor
  OWNER TO postgres;
