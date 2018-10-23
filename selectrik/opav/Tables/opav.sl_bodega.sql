-- Table: opav.sl_bodega

-- DROP TABLE opav.sl_bodega;

CREATE TABLE opav.sl_bodega
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  tipo_bodega integer NOT NULL,
  descripcion character varying(100) NOT NULL DEFAULT ''::character varying,
  id_solicitud character varying(15) NOT NULL DEFAULT ''::character varying,
  direccion character varying(80) NOT NULL DEFAULT ''::character varying,
  ubucacion_x character varying(80) NOT NULL DEFAULT ''::character varying,
  ubucacion_y character varying(80) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  ciudad character varying(4) NOT NULL DEFAULT ''::character varying,
  nombre_contacto character varying,
  cargo_contacto character varying,
  telefono1_contacto character varying,
  telefono2_contacto character varying,
  CONSTRAINT fk_idtipobodega FOREIGN KEY (tipo_bodega)
      REFERENCES opav.sl_tipo_bodega (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_bodega
  OWNER TO postgres;
